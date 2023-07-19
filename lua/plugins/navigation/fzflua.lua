return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons', optional = true },
  opts = {
    hls = {
      border = 'FloatBorder',
      preview_border = 'FloatBorder',
      help_border = 'FloatBorder',
      title = 'TelescopeTitle',
      preview_title = 'TelescopePreviewTitle',
    },
    files = {
      rg_opts = '--line-number --smart-case --no-ignore --ignore-exclude --files --hidden --follow'
    },
  }
}
