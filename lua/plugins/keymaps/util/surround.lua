---@alias KeymapSurround.BufferPosition [integer, integer, integer, integer]
---@alias KeymapSurround.Region [KeymapSurround.BufferPosition, KeymapSurround.BufferPosition]
---@alias KeymapSurround.OperatorType 'block'|'char'|'line'

---@class KeymapSurround
local M = {}

---@type table<string, [string, string]>
local PAIRS = {
  ['('] = { '(', ')' },
  [')'] = { '(', ')' },
  ['['] = { '[', ']' },
  [']'] = { '[', ']' },
  ['{'] = { '{', '}' },
  ['}'] = { '{', '}' },
  ['<'] = { '<', '>' },
  ['>'] = { '<', '>' },
}

---@type table<KeymapSurround.OperatorType, string>
local OPERATOR_MODES = {
  block = '\22',
  char = 'v',
  line = 'V',
}

---Return the byte offset immediately after the character at `pos`.
---@param pos KeymapSurround.BufferPosition
---@return integer
local function position_end_col(pos)
  local line = vim.api.nvim_buf_get_lines(pos[1], pos[2] - 1, pos[2], false)[1]
  local col = math.min(pos[3] - 1, #line)
  if col < #line then
    col = col + #vim.fn.strcharpart(line:sub(col + 1), 0, 1)
  end
  return col
end

---Surround the given regions.
---@param char string
---@param regions KeymapSurround.Region[]
---@param blockwise boolean
local function surround_regions(char, regions, blockwise)
  local pair = PAIRS[char] or { char, char }
  local selected_regions = blockwise and regions or { { regions[1][1], regions[#regions][2] } }

  for index = #selected_regions, 1, -1 do
    local start_pos, end_pos = unpack(selected_regions[index])
    local row = end_pos[2] - 1
    local end_col = position_end_col(end_pos)
    vim.api.nvim_buf_set_text(end_pos[1], row, end_col, row, end_col, { pair[2] })

    row = start_pos[2] - 1
    local start_col = start_pos[3] - 1
    vim.api.nvim_buf_set_text(start_pos[1], row, start_col, row, start_col, { pair[1] })
  end
end

---Surround the region prepared by `g@`.
---@param char string
---@param type KeymapSurround.OperatorType
local function surround_operator(char, type)
  local regions = vim.fn.getregionpos(vim.fn.getpos("'["), vim.fn.getpos("']"), {
    type = OPERATOR_MODES[type],
    eol = true,
  })
  surround_regions(char, regions, type == 'block')
end

---Prepare a repeatable surround operator for the active Visual selection.
---@public
---@return string keys
function M.visual()
  local char = vim.fn.getcharstr()
  if char == '\27' or char == '\3' then
    return '<Esc>'
  end

  ---@param type KeymapSurround.OperatorType
  local function operatorfunc(type) surround_operator(char, type) end

  vim.o.operatorfunc = operatorfunc
  return 'g@'
end

return M
