local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  vim.print("Installing lazy.nvim...")
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },

    { import = 'plugins' },
    { import = 'plugins.code' },
    { import = 'plugins.completion' },
    { import = 'plugins.editor' },
    { import = 'plugins.lsp' },
    { import = 'plugins.misc' },
    { import = 'plugins.navigation' },
    { import = 'plugins.notes' },
    { import = 'plugins.popup' },
    { import = 'plugins.telescope' },
    { import = 'plugins.theme' },
    { import = 'plugins.ui' },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = '*', -- try installing the latest stable version for plugins that support semver
  },
  ui = {
    border = 'rounded',
  },
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
        'netrwPlugin',
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
    patterns = {},   -- For example {'folke'}
    fallback = true, -- Fallback to git when local plugin doesn't exist
  },
})
