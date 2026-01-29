local satellite_enabled = true
local function toggle_satellite()
  vim.cmd(satellite_enabled and 'SatelliteDisable' or 'SatelliteEnable')
  satellite_enabled = not satellite_enabled
  vim.notify(
    (satellite_enabled and 'Enabled' or 'Disabled') .. ' Satellite',
    vim.log.levels.INFO,
    { title = 'Satellite' }
  )
end

return {
  'lewis6991/satellite.nvim',
  cond = not vim.g.started_by_firenvim,
  event = function() return { 'User LazyBufEnter' } end,
  dev = true,
  keys = {
    { '<leader>ut', toggle_satellite, desc = 'Toggle Satellite' },
  },
  opts = {
    current_only = true,
    winblend = vim.o.winblend,
    excluded_filetypes = {
      'OverseerList',
      'Telescope',
      'TelescopePreview',
      'TelescopePrompt',
      'TelescopeResults',
      'chatgpt-input',
      'cmp',
      'neo-tree',
      'telescope',
      'toggleterm',
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
  config = function(_, opts)
    require('satellite').setup(opts)
    vim.api.nvim_create_autocmd('BufEnter', {
      callback = function()
        if satellite_enabled then
          vim.defer_fn(function() vim.cmd('SatelliteRefresh') end, 200)
        end
      end,
    })
  end,
}
