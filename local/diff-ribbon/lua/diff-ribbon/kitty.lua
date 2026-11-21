---@class DiffRibbon.CellSize
---@field width number Pixels
---@field height number Pixels

---@class DiffRibbon.Transmission
---@field id integer
---@field bytes string RGBA pixels
---@field width integer Pixels
---@field height integer Pixels
---@field columns integer Cells
---@field rows integer Cells

local ffi = require('ffi')
local zlib = require('diff-ribbon.zlib')

local M = {}

-- Character Kitty replaces with a piece of the image.
local PLACEHOLDER = vim.fn.nr2char(0x10EEEE)

-- Row and column diacritics from the Kitty graphics protocol: index 0 is the first entry.
local diacritics = vim
  .iter(
    vim.split(
      '0305,030D,030E,0310,0312,033D,033E,033F,0346,034A,034B,034C,0350,0351,0352,0357,035B,0363,0364,0365,0366,0367,'
        .. '0368,0369,036A,036B,036C,036D,036E,036F,0483,0484,0485,0486,0487,0592,0593,0594,0595,0597,0598,0599,059C,'
        .. '059D,059E,059F,05A0,05A1,05A8,05A9,05AB,05AC,05AF,05C4,0610,0611,0612,0613,0614,0615,0616,0617,0657,0658,'
        .. '0659,065A,065B,065D,065E,06D6,06D7,06D8,06D9,06DA,06DB,06DC,06DF,06E0,06E1,06E2,06E4,06E7,06E8,06EB,06EC,'
        .. '0730,0732,0733,0735,0736,073A,073D,073F,0740,0741,0743,0745,0747,0749,074A,07EB,07EC,07ED,07EE,07EF,07F0,'
        .. '07F1,07F3,0816,0817,0818,0819,081B,081C,081D,081E,081F,0820,0821,0822,0823,0825,0826,0827,0829,082A,082B,'
        .. '082C,082D,0951,0953,0954,0F82,0F83,0F86,0F87,135D,135E,135F,17DD,193A,1A17,1A75,1A76,1A77,1A78,1A79,1A7A,'
        .. '1A7B,1A7C,1B6B,1B6D,1B6E,1B6F,1B70,1B71,1B72,1B73,1CD0,1CD1,1CD2,1CDA,1CDB,1CE0,1DC0,1DC1,1DC3,1DC4,1DC5,'
        .. '1DC6,1DC7,1DC8,1DC9,1DCB,1DCC,1DD1,1DD2,1DD3,1DD4,1DD5,1DD6,1DD7,1DD8,1DD9,1DDA,1DDB,1DDC,1DDD,1DDE,1DDF,'
        .. '1DE0,1DE1,1DE2,1DE3,1DE4,1DE5,1DE6,1DFE,20D0,20D1,20D4,20D5,20D6,20D7,20DB,20DC,20E1,20E7,20E9,20F0,2CEF,'
        .. '2CF0,2CF1,2DE0,2DE1,2DE2,2DE3,2DE4,2DE5,2DE6,2DE7,2DE8,2DE9,2DEA,2DEB,2DEC,2DED,2DEE,2DEF,2DF0,2DF1,2DF2,'
        .. '2DF3,2DF4,2DF5,2DF6,2DF7,2DF8,2DF9,2DFA,2DFB,2DFC,2DFD,2DFE,2DFF,A66F,A67C,A67D,A6F0,A6F1,A8E0,A8E1,A8E2,'
        .. 'A8E3,A8E4,A8E5,A8E6,A8E7,A8E8,A8E9,A8EA,A8EB,A8EC,A8ED,A8EE,A8EF,A8F0,A8F1,AAB0,AAB2,AAB3,AAB7,AAB8,AABE,'
        .. 'AABF,AAC1,FE20,FE21,FE22,FE23,FE24,FE25,FE26,10A0F,10A38,1D185,1D186,1D187,1D188,1D189,1D1AA,1D1AB,1D1AC,'
        .. '1D1AD,1D242,1D243,1D244',
      ','
    )
  )
  :map(
    ---@param code string
    ---@return string
    function(code)
      ---@diagnostic disable-next-line: missing-return-value
      return vim.fn.nr2char(tonumber(code, 16))
    end
  )
  :totable()

-- Each row and column needs its own diacritic, so this caps the overlay size.
M.max_cells = #diacritics

-- C calls that ask the terminal for its pixel size. pcall skips them when already declared.
pcall(ffi.cdef, 'typedef struct { unsigned short row, col, xpixel, ypixel; } diff_ribbon_winsize;')
pcall(ffi.cdef, 'int ioctl(int, int, ...);')
pcall(ffi.cdef, 'int open(const char *, int, ...);')
pcall(ffi.cdef, 'int close(int);')

-- Code of the "window size" request, which differs between macOS and Linux.
local TIOCGWINSZ = vim.fn.has('mac') == 1 and 0x40087468 or 0x5413

--- Cell size of the terminal behind `descriptor`, or nil when it does not report pixels.
---@param descriptor integer
---@return DiffRibbon.CellSize?
local function measure(descriptor)
  ---@type { row: integer, col: integer, xpixel: integer, ypixel: integer }
  local size = ffi.new('diff_ribbon_winsize')
  if ffi.C.ioctl(descriptor, TIOCGWINSZ, size) ~= 0 or size.col == 0 or size.xpixel == 0 then
    return nil
  end

  return { width = size.xpixel / size.col, height = size.ypixel / size.row }
end

--- Pixel size of one terminal cell. The Neovim server may not own the tty, so /dev/tty is tried last.
---@return DiffRibbon.CellSize?
function M.cell_size()
  -- Standard input, output and error usually point at the terminal.
  for descriptor = 0, 2 do
    local size = measure(descriptor)
    if size then
      return size
    end
  end

  -- Flag 2 opens it for reading and writing.
  local tty = ffi.C.open('/dev/tty', 2)
  if tty < 0 then
    return nil
  end

  local size = measure(tty)
  ffi.C.close(tty)
  return size
end

--- Send one graphics command to Kitty.
---@param command string
---@param payload? string
local function send(command, payload)
  vim.api.nvim_ui_send('\27_G' .. command .. (payload and ';' .. payload or '') .. '\27\\')
end

-- Kitty accepts at most this many base64 characters per message.
local CHUNK_SIZE = 4096

--- Split the base64 payload into messages. Only the first carries the image settings.
---@param command string
---@param payload string
---@return string[]
local function chunks(command, payload)
  local messages = {}

  for start = 1, #payload, CHUNK_SIZE do
    -- Tells Kitty whether more chunks follow this one.
    local more = start + CHUNK_SIZE <= #payload and 1 or 0
    local control = start == 1 and ('%s,m=%d'):format(command, more) or ('q=2,m=%d'):format(more)
    table.insert(messages, '\27_G' .. control .. ';' .. payload:sub(start, start + CHUNK_SIZE - 1) .. '\27\\')
  end

  return messages
end

--- Transmit the pixels inside the escape codes and create a virtual placement shown through placeholder cells.
--- Sending the data itself works wherever Kitty runs, even when Neovim runs in a container.
---@param transmission DiffRibbon.Transmission
function M.transmit(transmission)
  local compressed = zlib.compress(transmission.bytes)

  -- Image settings, plus `o=z` when the pixels are compressed.
  local command = ('a=T,U=1,f=32,t=d,q=2,i=%d,s=%d,v=%d,c=%d,r=%d%s'):format(
    transmission.id,
    transmission.width,
    transmission.height,
    transmission.columns,
    transmission.rows,
    compressed and ',o=z' or ''
  )

  -- One call keeps the chunks together, since Kitty needs them without other graphics codes between.
  vim.api.nvim_ui_send(table.concat(chunks(command, vim.base64.encode(compressed or transmission.bytes))))
end

--- Free image `id` in Kitty.
---@param id integer
function M.delete(id) send(('a=d,d=I,q=2,i=%d'):format(id)) end

--- Placeholder cell showing the image cell at `row` and `column` (both 0 based).
---@param row integer
---@param column integer
---@return string
function M.placeholder(row, column) return PLACEHOLDER .. diacritics[row + 1] .. diacritics[column + 1] end

return M
