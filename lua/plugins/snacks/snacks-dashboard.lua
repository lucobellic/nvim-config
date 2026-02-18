local logo_path = vim.fn.stdpath('config') .. '/local/logo/'
return {
  'snacks.nvim',
  lazy = false,
  opts = {
    dashboard = {
      enabled = not (vim.g.started_by_firenvim or vim.env.KITTY_SCROLLBACK_NVIM == 'true'),
      width = 72,
      autokeys = 'abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ',
      sections = {
        {
          section = 'terminal',
          align = 'center',
          cmd = logo_path .. 'rainbow-logo.sh --speed 20 --play ' .. logo_path .. 'rainbow-logo.cache',
          height = 14,
          width = 69,
          padding = 1,
        },
        {
          align = 'center',
          padding = 1,
          text = {
            { '  Update ', hl = 'Label' },
            { '  Sessions ', hl = '@property' },
            { '  Last Session ', hl = 'Number' },
            { '  Files ', hl = 'DiagnosticInfo' },
            { '  Recent ', hl = '@string' },
          },
        },
        { section = 'startup', padding = 1, icon = '' },
        { icon = '󰏓 ', title = 'Projects', section = 'projects', indent = 2, padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
        {
          section = 'terminal',
          icon = ' ',
          title = 'Git Status',
          enabled = vim.fn.isdirectory('.git') == 1 and vim.fn.executable('hub') == 1,
          cmd = 'hub diff --stat -B -M -C',
          height = 8,
          padding = 0,
          indent = 2,
        },
        { text = '', hidden = true, action = ':Lazy update', key = 'u' },
        { text = '', hidden = true, action = ':PersistenceLoadSession', key = 's' },
        { text = '', hidden = true, action = ':PersistenceLoadLast', key = 'l' },
        { text = '', hidden = true, action = function() Snacks.picker.files() end, key = 'f' },
        { text = '', hidden = true, action = function() Snacks.picker.recent() end, key = 'r' },
      },
    },
  },
}
