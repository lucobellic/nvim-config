local lazypath = vim.env.LAZY or vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(lazypath)

if not pcall(require, 'lazy') then
  -- stylua: ignore
  vim.api.nvim_echo(
    { { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } },
    true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require('lazy').setup({
  rocks = { hererocks = true },
  spec = {
    -- { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    {
      'AstroNvim/AstroNvim',
      version = '^5',
      import = 'astronvim.plugins',
      opts = {                       -- AstroNvim options must be set here with the `import` key
        mapleader = ' ',             -- This ensures the leader key must be configured before Lazy is set up
        maplocalleader = ',',        -- This ensures the localleader key must be configured before Lazy is set up
        icons_enabled = true,        -- Set to false to disable icons (if no Nerd Font is available)
        pin_plugins = nil,           -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
        update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
      },
    },
    { import = 'community' },
    { import = 'config.vscode' },
    { import = 'plugins.astronvim' },
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
  install = { colorscheme = { 'habamax', 'gruvbox' } },
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
        '2html_plugin',
        'bugreport',
        'compiler',
        'getscript',
        'getscriptPlugin',
        'gzip',
        'logipat',
        'matchit',
        -- "netrw",
        -- "netrwFileHandlers",
        -- "netrwPlugin",
        -- "netrwSettings",
        'optwin',
        'rrhelper',
        'spellfile_plugin',
        'synmenu',
        'syntax',
        'tar',
        'tarPlugin',
        'tohtml',
        'tutor',
        'vimball',
        'vimballPlugin',
        'zip',
        'zipPlugin',
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

require('config')
