return {
  {
    'lukas-reineke/headlines.nvim',
    enabled = false,
  },
  {
    'OXY2DEV/markview.nvim',
    enabled = false, -- Too buggy and slow to be usable
    opts = {
      checkboxes = {
        checked = { text = '󱍧', hl = 'DiagnosticOk' },
        unchecked = { text = '󱍫', hl = 'DiagnosticInfo' },
      },
    },
  },
  {
    'MeanderingProgrammer/markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
    opts = {
      file_types = { 'markdown', 'codecompanion' },
      render_modes = { 'n', 'c', 'i' },
      sign = {
        enabled = false,
        exclude = {
          buftypes = { 'nofile' },
        },
      },
      heading = {
        sign = false,
        icons = { '󰉫 ', '󰉬 ', '󰉭 ', '󰉮 ', '󰉯 ', '󰉰 ', '󰉴 ' },
      },
      bullet = {
        enabled = true,
        icons = { '•' },
        highlight = 'DiagnosticInfo',
      },
      checkbox = {
        unchecked = { icon = '󱍫', highlight = 'DiagnosticInfo' },
        checked = { icon = '󱍧', highlight = 'DiagnosticOk' },
        custom = {
          in_progress = { raw = '[+]', rendered = '󱍬', highlight = 'DiagnosticWarn' },
          wont_do = { raw = '[/]', rendered = '󱍮', highlight = 'DiagnosticError' },
          waiting = { raw = '[?]', rendered = '󱍥', highlight = 'DiagnosticWarn' },
        },
      },
    },
  },
}
