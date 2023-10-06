return {
  'ibhagwan/fzf-lua',
  event = 'BufWinEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons', optional = true },
  keys = {
    { '<leader>fF', '<cmd>FzfLua files<cr>', desc = 'Find All Files' },
    { '<leader>sG', '<cmd>FzfLua live_grep<cr>', desc = 'Grep' },
  },
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
      rg_opts = '--line-number --smart-case --no-ignore --no-ignore-exclude --files --hidden --follow'
    },
  }
}
