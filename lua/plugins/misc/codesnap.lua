return {
  'mistricky/codesnap.nvim',
  enabled = false,
  build = 'make',
  cmd = { 'CodeSnap', 'CodeSnapSave', 'CodeSnapASCII' },
  opts = {
    bg_theme = 'peach',
    code_font_family = 'CaskaydiaCove Nerd Font',
    has_breadcrumbs = true,
    watermark = 'neovim',
  },
}
