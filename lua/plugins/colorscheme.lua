return {

  { 'ellisonleao/gruvbox.nvim' },

  {
    url = 'git@github.com:lucobellic/ayugloom.nvim.git',
    name = 'ayugloom',
    dependencies = 'rktjmp/lush.nvim',
    dev = true,
    lazy = true,
  },

  -- Configure LazyVim to load colorscheme
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'ayugloom',
    },
  }
}
