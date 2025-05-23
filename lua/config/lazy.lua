local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  rocks = { hererocks = true },
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },

    -- Load extras first
    { import = 'plugins.extras' },

    { import = 'plugins' },
    { import = 'plugins.code' },
    { import = 'plugins.codecompanion' },
    { import = 'plugins.completion' },
    { import = 'plugins.editor' },
    { import = 'plugins.git' },
    { import = 'plugins.keymaps' },
    { import = 'plugins.lang' },
    { import = 'plugins.lsp' },
    { import = 'plugins.misc' },
    { import = 'plugins.navigation' },
    { import = 'plugins.notes' },
    { import = 'plugins.popup' },
    { import = 'plugins.snacks' },
    { import = 'plugins.telescope' },
    { import = 'plugins.terminal' },
    { import = 'plugins.theme' },
    { import = 'plugins.ui' },
  },
  ui = {
    border = vim.g.border.style,
    backdrop = 100,
  },
  defaults = { lazy = true },
  install = { colorscheme = { 'habamax', 'gruvbox', 'ayugloom' } },
  checker = { enabled = false }, -- automatically check for plugin updates
  change_detection = {
    -- automatically check for config file changes and reload the ui
    enabled = true,
    notify = false, -- get a notification when changes are found
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        'gzip',
        -- 'matchit',
        -- 'matchparen',
        -- 'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  dev = {
    -- directory where you store your local plugin projects
    path = '~/Development/personal',
    ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
    patterns = {}, -- For example {'folke'}
    fallback = true, -- Fallback to git when local plugin doesn't exist
  },
})
