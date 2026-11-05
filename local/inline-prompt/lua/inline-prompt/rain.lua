local config = require('inline-prompt.config')

---@class InlinePrompt.Cell
---@field [1] string Character
---@field [2] string Highlight group
---@field flash? boolean Keeps changing until erased

---@class InlinePrompt.Node
---@field col integer Next cell to draw
---@field writer boolean Draws characters, otherwise erases them
---@field head boolean Draws a bright character in front of the stream
---@field last_char? string Character under the head, faded once the head moves on
---@field expired? boolean

---@class InlinePrompt.Stream
---@field row integer
---@field timer integer Ticks before the next node spawns
---@field drawing boolean
---@field nodes InlinePrompt.Node[]
---@field cells InlinePrompt.Cell[]

---@class InlinePrompt.Layout
---@field start_row integer
---@field end_row integer
---@field width integer
---@field streams InlinePrompt.Stream[]

---@class InlinePrompt.Rain
local M = {}

-- Same letter codes as unimatrix.
local CHARACTER_SETS = {
  k = 'ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ',
  n = '1234567890',
  s = [[-=*_+|:<>"]],
}
CHARACTER_SETS.m = CHARACTER_SETS.k .. CHARACTER_SETS.n:rep(2) .. CHARACTER_SETS.s:rep(4)

---@type InlinePrompt.Cell
local BLANK = { ' ', 'InlinePromptRain' }

---@param list string Letter codes, repeated letters make a set more frequent
---@return string[] characters
local function characters_from(list)
  return vim
    .iter(vim.fn.split(list, '\\zs'))
    :map(
      function(letter) return vim.fn.split(assert(CHARACTER_SETS[letter], 'Unknown character set ' .. letter), '\\zs') end
    )
    :flatten()
    :totable()
end

-- Defined on each start, because a color scheme change clears them.
local function define_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  vim.api.nvim_set_hl(0, 'InlinePromptRain', { default = true, link = 'DiagnosticOk' })
  vim.api.nvim_set_hl(0, 'InlinePromptRainHead', { default = true, fg = normal.fg, bold = true })
end

---A drawn character. Some of them flash until an eraser removes them.
---@param char string
---@return InlinePrompt.Cell
local function character_cell(char)
  return { char, 'InlinePromptRain', flash = config.options.rain.flashers and math.random(10) == 1 }
end

---@param row integer
---@param width integer
---@return InlinePrompt.Stream
local function new_stream(row, width)
  local cells = {}
  for col = 1, width do
    cells[col] = BLANK
  end
  -- The first node comes within a second so every line shows activity quickly.
  return {
    row = row,
    timer = math.random(math.min(width, 10)),
    drawing = false,
    nodes = {},
    cells = cells,
  }
end

---Alternate between a writer and an eraser, with gaps sized like unimatrix.
---@param stream InlinePrompt.Stream
---@param width integer
local function spawn(stream, width)
  stream.drawing = not stream.drawing
  stream.timer = stream.drawing and math.random(3, math.max(3, width - 3)) or math.random(width)
  table.insert(stream.nodes, { col = 1, writer = stream.drawing, head = stream.drawing and math.random(3) == 1 })
end

---@param stream InlinePrompt.Stream
---@param node InlinePrompt.Node
---@param characters string[]
local function draw(stream, node, characters)
  if not node.writer then
    stream.cells[node.col] = BLANK
    return
  end

  local char = characters[math.random(#characters)]
  if not node.head then
    stream.cells[node.col] = character_cell(char)
    return
  end

  stream.cells[node.col] = { char, 'InlinePromptRainHead' }
  if node.last_char then
    stream.cells[node.col - 1] = character_cell(node.last_char)
  end
  node.last_char = char
end

---Move the nodes of a stream one step to the right.
---@param stream InlinePrompt.Stream
---@param width integer
---@param frame integer
---@param characters string[]
local function step(stream, width, frame, characters)
  if stream.timer == 0 then
    spawn(stream, width)
  end
  stream.timer = stream.timer - 1

  for _, node in ipairs(stream.nodes) do
    draw(stream, node, characters)
    node.col = node.col + 1

    if node.col > width then
      -- Fade the head left on the last cell.
      if node.head then
        stream.cells[width] = character_cell(node.last_char)
      end
      node.expired = true
    end
  end

  -- Like unimatrix, flashers change every third frame.
  if frame % 3 == 0 then
    for _, cell in ipairs(stream.cells) do
      if cell.flash then
        cell[1] = characters[math.random(#characters)]
      end
    end
  end

  stream.nodes = vim.iter(stream.nodes):filter(function(node) return not node.expired end):totable()
end

---Merge neighbor cells with the same highlight to send fewer chunks.
---@param cells InlinePrompt.Cell[]
---@return InlinePrompt.Cell[] chunks
local function chunks(cells)
  local result = {}
  for _, cell in ipairs(cells) do
    local last = result[#result]
    if last and last[2] == cell[2] then
      last[1] = last[1] .. cell[1]
    else
      result[#result + 1] = { cell[1], cell[2] }
    end
  end
  return result
end

---Rows covered by the range. A range ending at the start of a line does not cover it.
---@param range InlinePrompt.Range
---@return integer start_row, integer end_row
local function rows(range)
  local end_row = (range.end_col == 0 and range.end_row > range.start_row) and range.end_row - 1 or range.end_row
  return range.start_row, end_row
end

---Run a digital rain from the left to the right of the window on each line of the range until stopped.
---@public
---@param buf integer
---@param get_range fun(): InlinePrompt.Range? Current range, which can move while the request runs
---@return fun() stop
function M.start(buf, get_range)
  local options = config.options.rain
  local characters = characters_from(options.characters)
  local namespace = vim.api.nvim_create_namespace('')
  local timer = assert(vim.uv.new_timer())
  local frame = 0
  ---@type InlinePrompt.Layout?
  local layout

  define_highlights()

  local function stop()
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
    end
  end

  -- Streams restart only when the rows or the window width change, not on every edit.
  ---@param range InlinePrompt.Range
  ---@param width integer
  ---@return InlinePrompt.Stream[]
  local function current_streams(range, width)
    local start_row, end_row = rows(range)
    if not layout or layout.start_row ~= start_row or layout.end_row ~= end_row or layout.width ~= width then
      vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
      layout = {
        start_row = start_row,
        end_row = end_row,
        width = width,
        streams = vim
          .iter(vim.fn.range(start_row, end_row))
          :map(function(row) return new_stream(row, width) end)
          :totable(),
      }
    end
    return layout.streams
  end

  -- Unimatrix speed 100 has no delay; a timer needs at least a few milliseconds.
  local interval = math.max(10, (100 - options.speed) * 10)

  timer:start(
    0,
    interval,
    vim.schedule_wrap(function()
      local range = vim.api.nvim_buf_is_loaded(buf) and get_range()
      if not range then
        stop()
        return
      end

      -- Skip frames while the buffer is hidden.
      local window = vim.fn.bufwinid(buf)
      if window == -1 then
        return
      end
      local info = vim.fn.getwininfo(window)[1]
      local width = math.max(1, info.width - info.textoff)

      -- Reusing the extmark id updates it in place instead of creating a new one.
      for index, stream in ipairs(current_streams(range, width)) do
        step(stream, width, frame, characters)
        vim.api.nvim_buf_set_extmark(buf, namespace, stream.row, 0, {
          id = index,
          virt_text = chunks(stream.cells),
          virt_text_win_col = 0,
        })
      end

      frame = frame + 1
    end)
  )

  return stop
end

return M
