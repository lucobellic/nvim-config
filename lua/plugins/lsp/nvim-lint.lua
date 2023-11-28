return {
  'mfussenegger/nvim-lint',
  enabled = false,
  opts = function(_, opts)
    -- Configure cspell using config file
    local cspell_args = require('lint.linters.cspell').args
    local cspell_config_file = vim.fn.stdpath('config') .. '/spell/cspell.json'
    require('lint.linters.cspell').args = vim.tbl_extend('force', cspell_args, {
      '--config',
      cspell_config_file,
    })

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('lint', { clear = true }),
      pattern = '*',
      callback = function()
        require('lint').try_lint('cspell')
      end,
      desc = 'Lint cspell',
    })
  end,
}
