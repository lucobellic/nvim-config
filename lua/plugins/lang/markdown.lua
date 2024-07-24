return {
  {
    'lukas-reineke/headlines.nvim',
    enabled = false,
  },
  {
    'OXY2DEV/markview.nvim',
    enabled = false, -- Too buggy and slow to be usable
    opts = {
      -- Do not work
      -- headings = {
      --   shift_width = 0,
      -- },
      checkboxes = {
        checked = { text = '󱍧', hl = 'DiagnosticOk' },
        unchecked = { text = '󱍫', hl = 'DiagnosticInfo' },
      },
    },
  },
  {
    'MeanderingProgrammer/markdown.nvim',
    opts = {
      sign = {
        enabled = false,
      },
      heading = {
        sign = false,
        icons = { '󰉫 ', '󰉬 ', '󰉭 ', '󰉮 ', '󰉯 ', '󰉰 ', '󰉴 ' },
      },
      bullet = {
        enabled = false,
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
      -- code = {
      --   sign = false,
      -- },
    },
  },
}
