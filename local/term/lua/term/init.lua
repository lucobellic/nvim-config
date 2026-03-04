local M = {}

--- Setup configuration
---@param opts? TermManagerConfig
function M.setup(opts)
  require('term.config').config = vim.tbl_deep_extend('force', require('term.config').defaults, opts or {})
  M.setup_user_commands()
end

function M.setup_user_commands()
  local Core = require('term.core')

  -- Define User commands
  vim.api.nvim_create_user_command('TermToggle', function(args)
    local name = args.args ~= '' and args.args or nil
    Core.toggle(name)
  end, { nargs = '?', desc = 'Toggle terminal' })

  vim.api.nvim_create_user_command('ToggleTerminal', function(args)
    local name = args.args ~= '' and args.args or nil
    Core.toggle(name)
  end, { nargs = '?', desc = 'Toggle terminal' })

  vim.api.nvim_create_user_command('TermNew', function() Core.new() end, { desc = 'Create new terminal' })
  vim.api.nvim_create_user_command('TermNext', function() Core.next() end, { desc = 'Next terminal' })
  vim.api.nvim_create_user_command('TermPrev', function() Core.prev() end, { desc = 'Previous terminal' })
  vim.api.nvim_create_user_command('TermClose', function() Core.close() end, { desc = 'Close terminal' })

  vim.api.nvim_create_autocmd('VimResized', {
    pattern = '*',
    callback = function() Core.resize() end,
  })
end

return M
