return {
  'https://gitlab.com/HiPhish/jinja.vim',
  init = function()
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      pattern = { '*.html', '*.yaml' },
      callback = function()
        vim.notify('Jinja filetype adjustment', vim.log.levels.INFO, { title = 'Jinja' })
        vim.fn['jinja#AdjustFiletype']()
      end,
    })
  end,
  config = function() end,
}
