-- make all keymaps silent by default
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  -- Add custom repeatable option
  if opts.repeatable then
    ---@diagnostic disable-next-line: inject-field
    opts.repeatable = nil
    return keymap_set(mode, lhs, function(...)
      rhs(...)
      vim.fn['repeat#set'](vim.api.nvim_replace_termcodes(lhs, true, false, true))
    end, opts)
  end
  return keymap_set(mode, lhs, rhs, opts)
end

require('config.filetype')
require('config.neovide')
require('config.shell')
require('config.vscode')
require('util.autosave').setup()

-- Using astronvim instead of lazyvim the following includes are required
-- require('config.autocmds')
