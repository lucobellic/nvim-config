vim.lsp.enable({
  'codebook',
  'qmlls',
  'neocmake',
})

if vim.fn.has('nvim-0.12') == 1 then
  if vim.g.suggestions == 'copilot' then
    vim.lsp.enable('copilot')
    vim.lsp.inline_completion.enable()
  end
end

require('util.separators').setup({ enabled = false })
require('util.cpp').setup()
