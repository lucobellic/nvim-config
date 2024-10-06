return {
  {
    'lukas-reineke/headlines.nvim',
    enabled = false,
  },
  {
    'OXY2DEV/markview.nvim',
    enabled = false, -- Too buggy and slow to be usable
    ft = { 'markdown', 'codecompanion', 'quarto', 'rmd' },
    opts = {
      states = {
        { ' ', '+', 'x' },
      },
      filetypes = { 'markdown', 'quarto', 'rmd', 'codecompanion' },
      checkboxes = {
        checked = { text = '󱍧', hl = 'DiagnosticOk' },
        unchecked = { text = '󱍫', hl = 'DiagnosticInfo' },
        custom = {
          {
            match_string = '+',
            text = '󱍬',
            hl = 'DiagnosticInfo',
            scope_hl = nil,
          },
          {
            match_string = 'x',
            text = '󱍮',
            hl = 'DiagnosticError',
            scope_hl = nil,
          },
          {
            match_string = '?',
            text = '󱍥',
            hl = 'DiagnosticWarn',
            scope_hl = nil,
          },
        },
      },
      headings = {
        shift_width = 0,
        heading_1 = { sign = '', icons = { '󰉫' } },
        heading_2 = { sign = '', icons = { '󰉬' } },
        heading_3 = { sign = '', icons = { '󰉭' } },
        heading_4 = { sign = '', icons = { '󰉮' } },
        heading_5 = { sign = '', icons = { '󰉯' } },
        heading_6 = { sign = '', icons = { '󰉰' } },
      },
      code_blocks = { sign = false },
      list_items = {
        indent_size = 0,
        shift_width = 0,
        marker_dot = {
          add_padding = false,
        },
        marker_parenthesis = {
          add_padding = false,
        },
      },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
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
          in_progress = { raw = '[+]', rendered = '󱍬', highlight = 'DiagnosticInfo' },
          wont_do = { raw = '[/]', rendered = '󱍮', highlight = 'DiagnosticError' },
          waiting = { raw = '[?]', rendered = '󱍥', highlight = 'DiagnosticWarn' },
        },
      },
    },
  },
}
