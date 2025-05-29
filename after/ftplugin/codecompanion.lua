vim.keymap.set('n', 'gf', function() require('util.util').open_file() end, { buffer = 0 })
vim.keymap.set('i', '<c-cr>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', false)
  --- @type CodeCompanion.Chat
  local chat = require('codecompanion').buf_get_chat(0)
  chat:submit()
end, { desc = 'Send CodeCompanion Chat and Exit Insert Mode' })
