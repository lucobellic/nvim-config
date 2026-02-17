local M = {}

function M.setup()
  local iife_highlight = require('util.cpp.iife_highlight')
  local mutable_reference_hints = require('util.cpp.mutable_reference_hints')

  iife_highlight.setup()
  mutable_reference_hints.setup()

  vim.api.nvim_create_user_command('ToggleIIFEHighlight', iife_highlight.toggle, { desc = 'Toggle IIFE Highlight' })
end

return M
