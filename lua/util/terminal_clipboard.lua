---@class TerminalClipboard
local M = {}

---Yank a visual selection before updating the system clipboard asynchronously.
---@public
---@return nil
function M.yank_visual()
  local clipboard = vim.o.clipboard
  vim.o.clipboard = ''

  local ok, err = pcall(vim.cmd.normal, { args = { 'y' }, bang = true })
  vim.o.clipboard = clipboard
  if not ok then
    error(err)
  end

  local contents = vim.fn.getreg('"', true, true)
  local regtype = vim.fn.getregtype('"')
  vim.schedule(function() vim.fn.setreg('+', contents, regtype) end)
end

---Install terminal-safe visual yank behavior for the current buffer.
---@public
---@return nil
function M.setup() vim.keymap.set('x', 'y', M.yank_visual, { buffer = true, desc = 'Yank terminal selection' }) end

return M
