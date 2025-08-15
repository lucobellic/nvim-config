-- vim.cmd('runtime! ftplugin/markdown.vim')

local function set_markdown_folding()
  vim.wo['foldmethod'] = 'expr'
  vim.wo['foldexpr'] = 'MarkdownFold()'
  vim.wo['foldtext'] = 'MarkdownFoldText()'
end

-- vim.api.nvim_create_autocmd('BufEnter', {
--   buffer = 0,
--   callback = function() vim.defer_fn(set_markdown_folding, 250) end,
--   desc = 'Add CodeCompanion markdown folding',
-- })

vim.keymap.set('n', 'gf', function() require('util.util').open_file() end, { buffer = 0 })
vim.keymap.set('i', '<c-cr>', function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', false)
  --- @type CodeCompanion.Chat
  local chat = require('codecompanion').buf_get_chat(0)
  chat:submit()
end, { desc = 'Send CodeCompanion Chat and Exit Insert Mode', buffer = 0 })
