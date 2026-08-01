local filetypes = {
  'codecompanion',
  'codecompanion.floaterm',
  'markdown',
  'markdown.floaterm',
  'mcphub',
  'noice',
  'obsidian',
}

return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = filetypes,
  opts_extend = { 'file_types', 'render_modes', 'sign.exclude.buftypes' },
  opts = {
    file_types = filetypes,
    render_modes = true,
    restart_highlighter = false,
    sign = {
      enabled = false,
    },
    pipe_table = {
      border_enabled = false,
    },
    anti_conceal = {
      enabled = true,
    },
    heading = {
      sign = false,
      icons = {
        '█ ',
        '██ ',
        '███ ',
        '████ ',
        '█████ ',
        '██████ ',
        '███████ ',
      },
      width = 'block',
      right_pad = 1,
      border_prefix = false,
      border = false,
    },
    bullet = {
      enabled = true,
      icons = { '•' },
      highlight = 'DiagnosticInfo',
    },
    code = {
      border = 'thin',
    },
    checkbox = {
      enabled = true,
      bullet = true,
      unchecked = { icon = '󱍫 ', highlight = 'DiagnosticInfo' },
      checked = { icon = '󱍧 ', highlight = 'DiagnosticOk' },
      custom = {
        in_progress = { raw = '[~]', rendered = '󱍬 ', highlight = 'DiagnosticInfo' },
        wont_do = { raw = '[>]', rendered = '󱍮 ', highlight = 'DiagnosticError' },
        waiting = { raw = '[!]', rendered = '󱍥 ', highlight = 'DiagnosticWarn' },
      },
    },
  },
}
