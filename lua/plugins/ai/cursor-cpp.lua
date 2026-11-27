return {
  'lucobellic/cursor-cpp.nvim',
  url = 'git@github.com:lucobellic/cursor-cpp.nvim.git',
  dev = true,
  enabled = vim.g.suggestions == 'cursor-cpp',
  lazy = false,
  opts = { border = 'none', keymaps = { accept = false } },
  config = function(_, opts)
    -- Expose the health check at startup and start completion on the first edit.
    vim.api.nvim_create_autocmd('InsertEnter', {
      once = true,
      callback = function() require('cursor-cpp').setup(opts) end,
    })
  end,
}
