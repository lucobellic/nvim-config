vim.keymap.set('n', 'gf', function() require('util.util').open_file() end, { buffer = true })
vim.keymap.set('n', '<c-t>', '<cmd>CodeCompanionChat<cr>', { buffer = true, desc = 'Code Companion Chat' })
vim.keymap.set('i', '<c-cr>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', false)
  --- @type CodeCompanion.Chat
  local chat = require('codecompanion').buf_get_chat(0)
  chat:submit()
end, { desc = 'Send CodeCompanion Chat and Exit Insert Mode', buffer = true })

vim.keymap.set('n', '<localleader>b', '<NOP>', { buffer = true, remap = true, desc = 'buffers' })
vim.keymap.set('n', '<localleader>h', '<NOP>', { buffer = true, remap = true, desc = 'history' })
vim.keymap.set('n', '<localleader>t', '<NOP>', { buffer = true, remap = true, desc = 'toggle' })
