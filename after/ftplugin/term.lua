local core = require('util.term.core')

-- Disable spell checking in terminal buffers
vim.opt_local.spell = false

-- Disable animations from mini.animate
vim.b.miniindentscope_disable = true
vim.b.minianimate_disable = true

vim.keymap.set({ 't', 'n' }, '<C-q>', function()
  if core.active_term then
    core.remove(core.active_term.name)
  end
end, { buffer = true, silent = true, desc = 'Term Close' })

vim.keymap.set({ 'n' }, '<Esc>', function() core.hide() end, { buffer = true, silent = true, desc = 'Term Close' })

vim.keymap.set({ 't', 'n' }, '<C-t>', function() core.new() end, { buffer = true, silent = true, desc = 'Term New' })
vim.keymap.set(
  { 't', 'n' },
  '<C-r>',
  function() core.replace() end,
  { buffer = true, silent = true, desc = 'Term Replace' }
)
vim.keymap.set(
  { 't', 'n' },
  '<C-h>',
  function() core.prev() end,
  { buffer = true, silent = true, desc = 'Term Previous' }
)
vim.keymap.set({ 't', 'n' }, '<C-l>', function() core.next() end, { buffer = true, silent = true, desc = 'Term Next' })

vim.keymap.set(
  { 't', 'n' },
  '<C-Down>',
  function() core.increase_size() end,
  { buffer = true, silent = true, desc = 'Term Increase Size' }
)

vim.keymap.set(
  { 't', 'n' },
  '<C-Up>',
  function() core.decrease_size() end,
  { buffer = true, silent = true, desc = 'Term Decrease Size' }
)

vim.keymap.set('t', '<F7>', function() core.toggle() end, { buffer = true, silent = true, desc = 'Toggle Terminal' })
vim.keymap.set('n', 'q', function() core.toggle() end, { buffer = true, silent = true, desc = 'Toggle Terminal' })

-- Enable gf behavior for opening files under cursor
vim.keymap.set('n', 'gf', function() require('util.util').open_file() end, { buffer = true })
