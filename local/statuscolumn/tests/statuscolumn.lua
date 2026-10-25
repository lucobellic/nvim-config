vim.opt.runtimepath:prepend(vim.fn.getcwd() .. '/local/statuscolumn')

local statuscolumn = require('statuscolumn')
statuscolumn.setup()
statuscolumn.setup()
assert(#vim.api.nvim_get_autocmds({ group = 'UserStatuscolumn', event = 'ColorScheme' }) == 1)
assert(not package.loaded.heirline)

vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'one', 'two', 'three' })
vim.wo.number = true
vim.wo.signcolumn = 'yes:2'
vim.wo.foldcolumn = '1'
vim.wo.cursorline = true
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.api.nvim_set_hl(0, 'CursorLineNr', { bg = '#112233' })
vim.api.nvim_set_hl(0, 'TestStatuscolumnSign', { fg = '#ffffff', bg = '#445566' })

---@param line integer
---@param winid? integer
---@return vim.api.keyset.eval_statusline_ret
local function evaluate(line, winid)
  return vim.api.nvim_eval_statusline(vim.o.statuscolumn, {
    winid = winid or vim.api.nvim_get_current_win(),
    use_statuscol_lnum = line,
    highlights = true,
  })
end

local cursor_namespace = vim.api.nvim_create_namespace('cursor-tab.nvim.sign')
local git_namespace = vim.api.nvim_create_namespace('gitsigns_signs_')
local staged_namespace = vim.api.nvim_create_namespace('gitsigns_signs_staged')
local other_namespace = vim.api.nvim_create_namespace('test.statuscolumn')

---@param namespace integer
---@param text string
---@param priority integer
local function sign(namespace, text, priority)
  vim.api.nvim_buf_set_extmark(0, namespace, 0, 0, {
    sign_text = text,
    sign_hl_group = 'TestStatuscolumnSign',
    priority = priority,
  })
end

sign(other_namespace, 'D', 100)
sign(cursor_namespace, 'C', 1)
sign(staged_namespace, 'S', 100)
sign(git_namespace, 'G', 1)
local result = evaluate(1)
assert(result.str:find('CG', 1, true), result.str)
assert(result.str:find('1', 1, true), result.str)
local cursor_sign_highlight = false
vim.iter(result.highlights):each(
  ---@param highlight table
  function(highlight)
    vim.iter(highlight.groups):each(
      ---@param group string
      function(group)
        if group:find('StatusColumnCursorSign', 1, true) then
          assert(vim.api.nvim_get_hl(0, { name = group }).bg == 0x112233)
          cursor_sign_highlight = true
        end
      end
    )
  end
)
assert(cursor_sign_highlight)
assert(not evaluate(2).str:find('CG', 1, true))

vim.api.nvim_buf_clear_namespace(0, cursor_namespace, 0, -1)
assert(evaluate(1).str:find('DG', 1, true))
vim.cmd('doautocmd ColorScheme')
assert(evaluate(1).str:find('DG', 1, true))

vim.wo.signcolumn = 'no'
assert(vim.trim(evaluate(2).str) == '2')
vim.wo.number = false
assert(evaluate(2).str == '')
vim.wo.number = true
vim.g.zen_mode = true
assert(evaluate(1).str == '')
vim.g.zen_mode = false
vim.bo.buftype = 'nofile'
assert(evaluate(1).str == '')
vim.bo.buftype = ''

local original_window = vim.api.nvim_get_current_win()
vim.cmd('vnew')
vim.bo.buftype = 'nofile'
assert(vim.trim(evaluate(2, original_window).str) == '2')
vim.cmd('close')
vim.wo.signcolumn = 'yes:2'
vim.wo.foldmethod = 'manual'
vim.cmd('1,2fold')
assert(evaluate(1).str:find('+', 1, true), evaluate(1).str)

print('statuscolumn checks passed')
