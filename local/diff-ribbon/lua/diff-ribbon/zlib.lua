local ffi = require('ffi')

local M = {}

-- The two zlib calls this plugin needs. pcall skips them when already declared.
pcall(
  ffi.cdef,
  [[
  unsigned long compressBound(unsigned long source_length);
  int compress2(char *destination, unsigned long *destination_length, const char *source, unsigned long source_length, int level);
]]
)

--- Some systems only ship the versioned library, without the development link.
---@return ffi.namespace*?
local function load()
  return (
    vim
      .iter({ 'z', 'libz.so.1' })
      :map(
        ---@param name string
        ---@return ffi.namespace*?
        function(name)
          local loaded, library = pcall(ffi.load, name)
          -- Neovim annotates map callbacks as returning two values, but one is enough here.
          ---@diagnostic disable-next-line: missing-return-value
          return loaded and library or nil
        end
      )
      :next()
  )
end

-- Loaded once, nil when zlib is missing.
local library = load()

-- Fastest level: ribbon images are mostly transparent, so even light compression shrinks them a lot.
local LEVEL = 1

--- Compress with zlib, or return nil when zlib is missing or fails, so callers send the raw bytes.
---@param data string
---@return string?
function M.compress(data)
  if not library then
    return nil
  end

  -- Room for the worst case, so compression never runs out of space.
  local bound = library.compressBound(#data)
  local buffer = ffi.new('char[?]', bound)
  local length = ffi.new('unsigned long[1]', bound)

  local is_compressed = library.compress2(buffer, length, data, #data, LEVEL) == 0
  return is_compressed and ffi.string(buffer, length[0]) or nil
end

return M
