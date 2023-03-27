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

  -- Tasks
  'skywind3000/asyncrun.vim',
  'skywind3000/asynctasks.vim',
  { 'GustavoKatel/telescope-asynctasks.nvim', dependencies = { 'asynctasks.vim' } },

  -- Debugger
  'mfussenegger/nvim-dap',

  -- Other
  'lewis6991/impatient.nvim',
  'moll/vim-bbye', -- Close buffer and window
  'xolox/vim-misc',
  'honza/vim-snippets',
})


require('colors') -- Apply coloscheme configuration
require('mappings')
