-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'cpp' },
  command = 'setlocal commentstring=//\\ %s',
  desc = 'Set // as defalut comment string for c++',
})

-- Display cursorline only in focused window
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'WinEnter' }, {
  pattern = '*',
  command = 'setlocal cursorline',
  desc = 'Display cursorline only in focused window',
})
vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  pattern = '*',
  command = 'setlocal nocursorline',
  desc = 'Hide cursorline when leaving window',
})

-- Automatic save
require('util.autosave').setup()

-- Diagnostic toggle
vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualText',
  function()
    vim.diagnostic.config({
      virtual_text = not vim.diagnostic.config().virtual_text
    })
  end,
  { desc = 'Toggle diagnostic virtual text' }
)

vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualLines',
  function()
    vim.diagnostic.config({
      virtual_lines = not vim.diagnostic.config().virtual_lines
    })
  end,
  { desc = 'Toggle diagnostic virtual lines' }
)

vim.api.nvim_create_autocmd({ 'Filetype' }, {
  pattern = { 'dashboard', 'lspsagaoutline' },
  callback = function() vim.b.miniindentscope_disable = true end,
})


-- Load session from persistence
local persistence = require('persistence')

--- Get persistence sessions sorted by last modification time
local get_sorted_sessions = function()
  local sessions = persistence.list()
  table.sort(sessions, function(a, b)
    return vim.loop.fs_stat(a).mtime.sec > vim.loop.fs_stat(b).mtime.sec
  end)
  return sessions
end

--- Get session path from persistence session list
---@param session string session with '%' to be replaced with '/'
local get_session_path = function(session)
  local pos = session:find('%%')
  local session_path = pos and session:sub(pos) or session
  return session_path:gsub('%%', '/'):gsub('.vim$', '')
end


--- Use vim.ui.select() to load session from persistence plugin
local load_session = function()
  local sessions = get_sorted_sessions()

  local display_names = {}
  for _, session in ipairs(sessions) do
    local session_path = get_session_path(session)
    table.insert(display_names, session_path)
  end

  vim.ui.select(display_names, { prompt = 'Load Session' }, function(_, idx)
    if idx then
      local session_file = sessions[idx]
      if session_file and vim.fn.filereadable(session_file) ~= 0 then
        vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
      end
    end
  end)
end

vim.api.nvim_create_user_command('PersistenceLoadSession', load_session, {})

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
    vim.cmd("colorscheme ayugloom")
  else
    vim.cmd("colorscheme ayubleak")
  end
  vim.g.transparent_colorscheme = not vim.g.transparent_colorscheme
end
vim.api.nvim_create_user_command("TransparencyToggle", toggle_transparency, {})

-- Override diagnostic signs to set line color and remove
-- TODO: Move to appropriate configuration file
for name, icon in pairs(require("lazyvim.config").icons.diagnostics) do
  local hl = "DiagnosticSign" .. name
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
  callback = function()
    require('util.tabpages').focus_first_listed_buffer()
  end
})
