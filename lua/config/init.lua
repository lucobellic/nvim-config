require('config.filetype')
require('config.neovide')
require('config.shell')

-- make all keymaps silent by default
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  -- Add custom repeatable option
  if opts.repeatable then
    opts.repeatable = nil
    return keymap_set(mode, lhs, function(...)
      rhs(...)
      vim.fn['repeat#set'](vim.api.nvim_replace_termcodes(lhs, true, false, true))
    end, opts)
  end
  return keymap_set(mode, lhs, rhs, opts)
end

require('config.lazy')
