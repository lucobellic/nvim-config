-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'cpp' },
  command = 'setlocal commentstring=//\\ %s',
  desc = 'Set // as default comment string for c++',
})

-- Display cursorline only in focused window
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'WinEnter' }, {
  pattern = '*',
  command = 'setlocal cursorline',
  desc = 'Display cursorline only in focused window',
})
vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  pattern = '*',
  callback = function(ev)
    local current_filetype = vim.api.nvim_get_option_value('filetype', { buf = ev.buf }):lower()
    local ignored_list = { 'neo-tree', 'outline' }
    for _, ft_ignored in ipairs(ignored_list) do
      if ft_ignored == current_filetype then
        return
      end
    end
    vim.cmd('setlocal nocursorline')
  end,
  desc = 'Hide cursorline when leaving window',
})

-- Automatic save
require('util.autosave').setup()

-- Diagnostic toggle
vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualText',
  function()
    vim.diagnostic.config({
      virtual_text = not vim.diagnostic.config().virtual_text,
    })
  end,
  { desc = 'Toggle diagnostic virtual text' }
)

vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualLines',
  function()
    vim.diagnostic.config({
      virtual_lines = not vim.diagnostic.config().virtual_lines,
    })
  end,
  { desc = 'Toggle diagnostic virtual lines' }
)

vim.api.nvim_create_autocmd({ 'Filetype' }, {
  pattern = { 'dashboard', 'lspsagaoutline' },
  callback = function() vim.b.miniindentscope_disable = true end,
})

-- Load session from persistence
local persistence_util = require('util.persistence')
vim.api.nvim_create_user_command('PersistenceLoadSession', persistence_util.select_session, {})

-- Define a function to handle the BufEnter event
local function on_buffer_enter()
  if vim.bo.filetype ~= 'dashboard' then
    vim.api.nvim_exec_autocmds('User', { pattern = 'BufEnterExceptDashboard' })
  end
end

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  pattern = { '*' },
  callback = on_buffer_enter,
})

-- Switch colorscheme with transparency
vim.g.transparent_colorscheme = false
local toggle_transparency = function()
  if vim.g.transparent_colorscheme then
    vim.cmd('colorscheme ayugloom')
  else
    vim.cmd('colorscheme ayubleak')
  end
  vim.g.transparent_colorscheme = not vim.g.transparent_colorscheme
end
vim.api.nvim_create_user_command('TransparencyToggle', toggle_transparency, {})

-- Override diagnostic signs to set line color and remove icon
-- TODO: Move to appropriate configuration file
for name, icon in pairs(require('lazyvim.config').icons.diagnostics) do
  local hl = 'DiagnosticSign' .. name
  if name == 'Hint' or name == 'Info' then
    vim.fn.sign_define(hl, { text = '', texthl = hl, numhl = '' })
  else
    vim.fn.sign_define(hl, { text = '', texthl = hl, numhl = hl })
  end
end

vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

-- Always focus on buffer after tab change
vim.api.nvim_create_autocmd({ 'TabEnter' }, {
  pattern = { '*' },
  callback = function() require('util.tabpages').focus_first_listed_buffer() end,
})
