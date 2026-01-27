return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'codecompanion', 'mcphub', 'obsidian' },
  opts_extend = { 'file_types', 'render_modes', 'sign.exclude.buftypes' },
  opts = {
    file_types = {
      'markdown',
      'markdown.floaterm',
      'codecompanion',
      'codecompanion.floaterm',
      'mcphub',
      'obsidian',
      'noice',
    },
    render_modes = { 'n', 'c', 'i' },
    restart_highlighter = false,
    sign = {
      enabled = false,
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
      border = true,
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
