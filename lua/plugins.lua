local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'dstein64/vim-startuptime',
    'kkharji/sqlite.lua',
    require('plugin.completion'),
    require('plugin.lsp'),
    require('plugin.navigation'),
    require('plugin.preview'),
    require('plugin.ui'),
    require('plugin.editor'),
    require('plugin.telescope'),
    require('plugin.dap'),

    -- Tasks
    'skywind3000/asyncrun.vim',
    'skywind3000/asynctasks.vim',
    { 'GustavoKatel/telescope-asynctasks.nvim', dependencies = { 'asynctasks.vim' } },

    -- Other
    'lewis6991/impatient.nvim',
    'moll/vim-bbye', -- Close buffer and window
    'xolox/vim-misc',
    'honza/vim-snippets',
  },
  {
    dev = {
      -- directory where you store your local plugin projects
      path = "~/Development/personal",
      ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
      patterns = {},   -- For example {"folke"}
      fallback = true, -- Fallback to git when local plugin doesn't exist
    },
  }
)


require('colors') -- Apply coloscheme configuration
require('mappings')
