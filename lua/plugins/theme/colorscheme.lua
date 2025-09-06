return {
  {
    'lucobellic/ayugloom.nvim',
    name = 'ayugloom',
    dependencies = 'rktjmp/lush.nvim',
    dev = true,
    init = function()
      if not vim.g.distribution then
        vim.cmd([[colorscheme ayugloom]])
      end
    end,
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
  { 'EdenEast/nightfox.nvim' },
  { 'RedsXDD/neopywal.nvim' },
  { 'Shatur/neovim-ayu' },
  { 'dasupradyumna/midnight.nvim' },
  { 'folke/tokyonight.nvim' },
  { 'fynnfluegge/monet.nvim' },
  { 'gbprod/nord.nvim' },
  { 'neko-night/nvim' },
  { 'rebelot/kanagawa.nvim' },
  { 'rmehri01/onenord.nvim' },
  { 'rockerBOO/boo-colorscheme-nvim' },
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'samharju/serene.nvim' },
  { 'samharju/synthweave.nvim' },
  { 'scottmckendry/cyberdream.nvim' },
  { 'thesimonho/kanagawa-paper.nvim' },
}
