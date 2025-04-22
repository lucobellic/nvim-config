return {
  'mfussenegger/nvim-lint',
  opts = function(_, opts)
    local lint = require('lint')

    lint.linters.cspell = require('lint.util').wrap(lint.linters.cspell, function(diagnostic)
      diagnostic.severity = vim.diagnostic.severity.HINT
      return diagnostic
    end)

    lint.linters.cspell.args = vim.tbl_extend('force', lint.linters.cspell.args, {
      '--config',
      vim.fn.stdpath('config') .. '/spell/cspell.json',
    })

    vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufEnter', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('lint', { clear = true }),
      pattern = '*',
      callback = function() require('lint').try_lint('cspell') end,
      desc = 'Lint cspell',
    })
    return opts
  end,
}
