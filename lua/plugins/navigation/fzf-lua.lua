return {
  {
    'junegunn/fzf',
    build = './install --bin',
    config = function() end,
  },
  {
    'junegunn/fzf.vim',
    config = function() end,
  },
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons', optional = true },
    cmd = { 'FzfLua' },
    opts = {
      hls = {
        border = 'FloatBorder',
        preview_border = 'FloatBorder',
        help_border = 'FloatBorder',
        title = 'TelescopeTitle',
        preview_title = 'TelescopePreviewTitle',
      },
      files = {
        cmd = 'rg --line-number --smart-case --no-ignore --no-ignore-exclude --files --hidden --follow',
        rg_opts = '--line-number --smart-case --no-ignore --no-ignore-exclude --files --hidden --follow',
      },
    },
  },
}
