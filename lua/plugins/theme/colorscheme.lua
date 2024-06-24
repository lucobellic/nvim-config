return {
  {
    'lucobellic/ayugloom.nvim',
    name = 'ayugloom',
    dependencies = 'rktjmp/lush.nvim',
    priority = 1000,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    opts = {
      transparent_background = false,
      integrations = {
        indent_blankline = {
          enabled = true,
          colored_indent_levels = true,
        },
      },
    },
    priority = 1000,
  },
  { 'ellisonleao/gruvbox.nvim' },
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'EdenEast/nightfox.nvim' },
  { 'oxfist/night-owl.nvim' },
}
