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
      vim.api.nvim_create_user_command('AyugloomCompile', function() require('ayugloom.compiler').compile() end, {})
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
}
