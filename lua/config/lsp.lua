vim.lsp.enable({
  'codebook',
  'qmlls',
  'neocmake',
})

if vim.fn.has('nvim-0.12') == 1 then
  if vim.g.suggestions == 'copilot' then
    vim.lsp.enable('copilot')
    vim.lsp.inline_completion.enable()

    -- Enable copilot for codecompanion buffers
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'codecompanion' },
      callback = function(args)
        if vim.g.suggestions then
          vim.lsp.start(vim.lsp.config['copilot'], { bufnr = args.buf })
        end
      end,
    })
  end
end

require('util.separators').setup({ enabled = false })
require('util.cpp').setup()
