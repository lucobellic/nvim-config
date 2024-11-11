local satellite_enabled = true
local function toggle_satellite()
  vim.cmd(satellite_enabled and 'SatelliteDisable' or 'SatelliteEnable')
  satellite_enabled = not satellite_enabled
  vim.notify((satellite_enabled and 'Enabled' or 'Disabled') .. ' Satellite')
end

return {
  'lewis6991/satellite.nvim',
  enabled = not vim.g.started_by_firenvim,
  event = 'BufEnter',
  keys = {
    { '<leader>ut', toggle_satellite, desc = 'Toggle Satellite' },
  },
  opts = {
    current_only = true,
    winblend = vim.o.winblend,
    excluded_filetypes = {
      'OverseerList',
      'neo-tree',
      'telescope',
      'Telescope',
      'TelescopePrompt',
      'TelescopeResults',
      'TelescopePreview',
      'chatgpt-input',
      'cmp',
    },
    handlers = {
      cursor = {
        enable = false, -- Refresh on CursorMoved is too slow
        symbols = { '│', '│' },
      },
      search = {
        enable = true,
        priority = 55, -- Below cursor and above diagnostic
      },
      diagnostic = {
        enable = true,
        signs = { '┊', '┊', '┊' },
        min_severity = vim.diagnostic.severity.WARN,
      },
      gitsigns = {
        enable = true,
        signs = {
          add = '│',
          change = '│',
          delete = '│',
        },
      },
      marks = {
        enable = false,
        show_builtins = false, -- shows the builtin marks like [ ] < >
        key = 'm',
      },
      quickfix = {
        enable = false,
        signs = { '│', '│', '│' },
      },
    },
  },
}
