-- TODO: Convert to plugin
local M = {}

-- Fold the current line if the cursor is at the indentation level
function M.h()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local to_fold = vim.fn.foldlevel(row) ~= 0 and col <= vim.fn.indent(row)
  local key = to_fold and 'zc' or 'h'
  vim.api.nvim_feedkeys(key, 'n', false)
end

function M.setup() vim.keymap.set('n', 'h', M.h, { noremap = true }) end

return M
