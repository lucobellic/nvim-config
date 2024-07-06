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
}
