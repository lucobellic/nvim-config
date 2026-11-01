---@class InlinePrompt.Range
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer

---@class InlinePrompt.RangeModule
local M = {}

---Read the visual selection. In normal mode, use the current line or an empty range at the cursor.
---@public
---@param use_line boolean
---@return InlinePrompt.Range
function M.current(use_line)
  local mode = vim.fn.mode()

  if mode == 'v' then
    local region = vim.fn.getregionpos(vim.fn.getpos('v'), vim.fn.getpos('.'), { type = 'v' })
    local first, last = region[1][1], region[#region][2]
    return {
      start_row = first[2] - 1,
      start_col = first[3] - 1,
      end_row = last[2] - 1,
      -- The cursor can sit past the end of the line, for example after `$`.
      end_col = math.min(last[3], #vim.fn.getline(last[2])),
    }
  end

  -- Block selections have no single range to replace, so they cover whole lines.
  if mode == 'V' or mode == '\22' or use_line then
    local first, last = vim.fn.line('v'), vim.fn.line('.')
    local start_line, end_line = math.min(first, last), math.max(first, last)
    return {
      start_row = start_line - 1,
      start_col = 0,
      end_row = end_line - 1,
      end_col = #vim.fn.getline(end_line),
    }
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  return { start_row = cursor[1] - 1, start_col = cursor[2], end_row = cursor[1] - 1, end_col = cursor[2] }
end

return M
