vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. '/local/statusline')

local components = require('statusline.components')
local events = require('statusline.events')
local statusline = require('statusline')
local theme = require('statusline.theme')

vim.o.laststatus = 3
vim.o.columns = 180
vim.o.cmdheight = 0
require('plugins.ui.statusline').config()

---@return vim.api.keyset.eval_statusline_ret
local function evaluate()
  return vim.api.nvim_eval_statusline(vim.o.statusline, { maxwidth = vim.o.columns, highlights = true })
end

local initial = evaluate().str
assert(initial:find('  ', 1, true) == 1)
assert(initial:find('  ', 1, true))
assert(initial:find('  ', 1, true))
assert(not package.loaded.dap)
assert(not package.loaded.overseer)
assert(not package.loaded['lsp-progress'])
assert(not package.loaded.layout)

vim.b.gitsigns_status_dict = { head = 'feature%branch' }
package.loaded['lazy.status'] = {
  ---@return boolean
  has_updates = function() return true end,
  ---@return string
  updates = function() return 'UPDATES' end,
}
package.loaded.dap = {
  ---@return table
  session = function() return {} end,
  ---@return string
  status = function() return 'stopped%here' end,
}
package.loaded.overseer = {
  ---@param options table
  ---@return table[]
  list_tasks = function(options)
    assert(options.unique)
    return { { status = 'SUCCESS' }, { status = 'RUNNING' }, { status = 'RUNNING' } }
  end,
}
local expected_window = vim.api.nvim_get_current_win()
local progress_window
package.loaded['lsp-progress'] = {
  ---@return string
  progress = function()
    progress_window = vim.api.nvim_get_current_win()
    return 'LSP%'
  end,
}
vim.g.layout = 'layout'
package.loaded.layout = {
  ---@param side string
  ---@return string[]
  get_statusline = function(side)
    assert(side == 'bottom')
    return { '%#Title#CENTER%*' }
  end,
}

local recording = vim.fn.reg_recording
---@return string
vim.fn.reg_recording = function() return 'q' end
local searchcount = vim.fn.searchcount
---@return table
vim.fn.searchcount = function() return { current = 2, total = 4, maxcount = 999 } end
vim.v.hlsearch = 1

local result = evaluate()
local text = result.str
assert(text:find('   feature%branch UPDATES   stopped%here q', 1, true) == 1)
assert(text:find(' 2  1 LSP%   [2/4]    ', 1, true), text)
assert(progress_window == expected_window)
local center_byte = assert(text:find('CENTER', 1, true))
assert(vim.fn.strdisplaywidth(text:sub(1, center_byte - 1)) == math.floor((vim.o.columns - 6) / 2))

local get_mode = vim.api.nvim_get_mode
local mode = 'n'
---@return table
vim.api.nvim_get_mode = function() return { mode = mode } end
local context = {
  winid = expected_window,
  bufnr = vim.api.nvim_get_current_buf(),
  width = vim.o.columns,
  active = true,
}
vim
  .iter({
    { 'n', 'Normal', '#70809b' },
    { 'i', 'Insert', '#AAD94C' },
    { 'v', 'Visual', '#FFB454' },
    { 'V', 'Visual', '#FFB454' },
    { '\22', 'Visual', '#FFB454' },
    { 'c', 'Command', '#59C2FF' },
    { 's', 'Select', '#D2A6FF' },
    { 'R', 'Replace', '#F07178' },
    { 't', 'Terminal', '#D2A6FF' },
  })
  :each(
    ---@param entry string[]
    function(entry)
      mode = entry[1]
      local primary, secondary = theme.groups()
      assert(primary == 'UserStatuslinePrimary' .. entry[2])
      assert(secondary == 'UserStatuslineSecondary' .. entry[2])
      local highlight = vim.api.nvim_get_hl(0, { name = primary })
      local color = tonumber(entry[3]:sub(2), 16)
      if mode == 'n' then
        assert(highlight.fg == color and highlight.bg == nil)
      else
        assert(highlight.bg == color and highlight.fg == tonumber('0F131A', 16))
        assert(components.left(context):find('┃', 1, true))
      end
    end
  )
vim.api.nvim_get_mode = get_mode

vim.api.nvim_set_hl(0, 'UserStatuslinePrimaryInsert', {})
vim.api.nvim_exec_autocmds('ColorScheme', {})
assert(vim.api.nvim_get_hl(0, { name = 'UserStatuslinePrimaryInsert' }).bg == tonumber('AAD94C', 16))
vim.api.nvim_set_hl(0, 'OverseerSUCCESS', { fg = '#123456', bg = '#654321', bold = true })
vim.api.nvim_exec_autocmds('User', { pattern = 'OverseerListUpdate' })
local task_highlight = vim.api.nvim_get_hl(0, { name = 'UserStatuslineTaskSUCCESS' })
assert(task_highlight.fg == tonumber('123456', 16))
assert(task_highlight.bg == nil and task_highlight.bold == nil)

local set_highlight = vim.api.nvim_set_hl
---@param namespace integer
---@param name string
---@param highlight table
vim.api.nvim_set_hl = function(namespace, name, highlight) error('Highlights must not be created while rendering') end
evaluate()
vim.api.nvim_set_hl = set_highlight

vim.api.nvim_exec_autocmds('User', { pattern = 'CodeCompanionRequestStarted' })
local spinner = events.codecompanion()
assert(not spinner:find('', 1, true))
assert(events.codecompanion() == spinner)
assert(vim.wait(
  500,
  ---@return boolean
  function() return events.codecompanion() ~= spinner end,
  20
))
vim.api.nvim_exec_autocmds('User', { pattern = 'CodeCompanionRequestStarted' })
vim.api.nvim_exec_autocmds('User', { pattern = 'CodeCompanionRequestFinished' })
assert(not events.codecompanion():find('', 1, true))
vim.api.nvim_exec_autocmds('User', { pattern = 'CodeCompanionRequestFinished' })
assert(events.codecompanion() == '  ')

vim.cmd('vsplit')
local current = vim.api.nvim_get_current_win()
context.active = false
components.right(context)
assert(progress_window == expected_window)
assert(vim.api.nvim_get_current_win() == current)

vim.fn.reg_recording = recording
vim.fn.searchcount = searchcount
vim.api.nvim_exec_autocmds('User', { pattern = 'CodeCompanionRequestStarted' })
events.setup()
assert(events.codecompanion() == '  ')
assert(vim.o.statusline:find("require'statusline'", 1, true))
assert(statusline.highlight('text', 'Title', 'Normal') == '%#Title#text%#Normal#')

print('Statusline configuration checks passed')
