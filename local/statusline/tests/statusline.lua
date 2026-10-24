vim.opt.runtimepath:prepend(vim.fn.getcwd() .. '/local/statusline')

local statusline = require('statusline')

---@param options User.Statusline.Options
---@param width integer
---@param winid? integer
---@return vim.api.keyset.eval_statusline_ret
local function evaluate(options, width, winid)
  statusline.setup(options)
  return vim.api.nvim_eval_statusline(vim.o.statusline, {
    winid = winid or vim.api.nvim_get_current_win(),
    maxwidth = width,
    highlights = true,
  })
end

---@param width integer
local function check_center(width)
  vim.o.columns = width
  local result = evaluate({
    left = { { provider = 'LLLLLL' } },
    center = { { provider = 'CENTER' } },
    right = { { provider = 'R' } },
  }, width)
  assert(result.width == width)
  assert(result.str:find('CENTER', 1, true) == math.floor((width - 6) / 2) + 1)
  assert(result.str:sub(1, 6) == 'LLLLLL')
  assert(result.str:sub(-1) == 'R')
end

vim.o.laststatus = 3
vim.iter({ 40, 41 }):each(check_center)

vim.o.columns = 40
local unicode = evaluate(
  { left = { { provider = '界' } }, center = { { provider = '界é' } }, right = { { provider = 'R' } } },
  40
)
local center_byte = assert(unicode.str:find('界é', 4, true))
assert(vim.fn.strdisplaywidth(unicode.str:sub(1, center_byte - 1)) == 18)
assert(unicode.width == 40)

local escaped = evaluate({ center = { { provider = '100%' } } }, 40)
assert(escaped.str:find('100%', 1, true) == 19)

---@param options User.Statusline.Options
local function check_overflow(options)
  local result = evaluate(options, 40)
  assert(not result.str:find('C', 1, true))
  assert(result.width == 40)
end

vim
  .iter({
    {
      left = { { provider = string.rep('L', 20) } },
      center = { { provider = 'CENTER' } },
      right = { { provider = 'R' } },
    },
    {
      left = { { provider = 'L' } },
      center = { { provider = 'CENTER' } },
      right = { { provider = string.rep('R', 20) } },
    },
    { left = { { provider = 'L' } }, center = { { provider = string.rep('C', 50) } }, right = { { provider = 'R' } } },
  })
  :each(check_overflow)

local truncated = evaluate({
  left = { { provider = string.rep('L', 60) } },
  center = { { provider = 'CENTER' } },
  right = { { provider = 'RIGHT' } },
}, 40)
assert(truncated.width == 40)
assert(truncated.str:sub(-5) == 'RIGHT')

local calls = 0
local measure = vim.api.nvim_eval_statusline
---@param format string
---@param options? vim.api.keyset.eval_statusline
---@return vim.api.keyset.eval_statusline_ret
vim.api.nvim_eval_statusline = function(format, options)
  calls = calls + 1
  return measure(format, options)
end
statusline.setup({ left = { { provider = 'L' } }, right = { { provider = 'R' } } })
statusline.render()
assert(calls == 0)
vim.api.nvim_eval_statusline = measure

local original = vim.api.nvim_get_current_win()
vim.cmd('vsplit')
local current = vim.api.nvim_get_current_win()
local target_buffer = vim.api.nvim_create_buf(true, false)
vim.api.nvim_win_set_buf(original, target_buffer)
vim.api.nvim_buf_set_lines(target_buffer, 0, -1, false, { 'first', 'second', 'third' })
vim.api.nvim_win_set_cursor(original, { 2, 0 })
vim.bo[target_buffer].filetype = 'lua'

vim.o.laststatus = 2
vim.api.nvim_win_set_width(original, 18)
local window_width = vim.api.nvim_win_get_width(original)
local providers = 0
local result = evaluate({
  left = {
    {
      ---@param context User.Statusline.Context
      ---@return string
      provider = function(context)
        providers = providers + 1
        assert(context.winid == original)
        assert(context.bufnr == target_buffer)
        assert(context.width == window_width)
        assert(not context.active)
        return '%l'
      end,
      format = true,
    },
  },
  center = {
    {
      ---@param _ User.Statusline.Context
      ---@return string
      provider = function(_)
        providers = providers + 1
        return '%y'
      end,
      format = true,
    },
  },
  right = {
    {
      ---@param _ User.Statusline.Context
      ---@return string
      provider = function(_)
        providers = providers + 1
        return 'R'
      end,
    },
  },
}, window_width, original)
assert(providers == 3)
assert(result.str:sub(1, 1) == '2')
assert(result.str:find('[lua]', 1, true) == math.floor((window_width - 5) / 2) + 1)
assert(vim.api.nvim_get_current_win() == current)

vim.o.laststatus = 3
local global = evaluate({
  center = {
    {
      ---@param context User.Statusline.Context
      ---@return string
      provider = function(context)
        assert(context.width == vim.o.columns)
        assert(context.active)
        return 'CENTER'
      end,
    },
  },
}, vim.o.columns, current)
assert(global.str:find('CENTER', 1, true) == math.floor((vim.o.columns - 6) / 2) + 1)

vim.api.nvim_set_hl(0, 'StatuslineTest', { fg = '#ff0000' })
local highlighted = evaluate({
  left = { { provider = 'L', hl = 'StatuslineTest' } },
  center = { { provider = 'CENTER' } },
  right = { { provider = 'R' } },
}, vim.o.columns)
assert(highlighted.highlights[1].groups[#highlighted.highlights[1].groups] == 'StatuslineTest')
assert(highlighted.highlights[2].start == 1)
assert(not vim.tbl_contains(highlighted.highlights[2].groups, 'StatuslineTest'))

local padded = evaluate({
  left = {
    { provider = 'X', padding = { left = 1, right = 2 } },
    { provider = '', padding = { left = 3, right = 3 } },
  },
}, vim.o.columns)
assert(padded.str:sub(1, 4) == ' X  ')
assert(padded.width == vim.o.columns)
assert(not statusline.render():find('   ', 1, true))

local visible = false
local cached_calls = 0
local highlight = 'Title'
statusline.setup({
  left = {
    {
      ---@param _ User.Statusline.Context
      ---@return boolean
      condition = function(_) return visible end,
      ---@param context User.Statusline.Context
      ---@return string
      provider = function(context)
        cached_calls = cached_calls + 1
        return tostring(context.bufnr)
      end,
      ---@param _ User.Statusline.Context
      ---@return string
      hl = function(_) return highlight end,
      update = { { event = 'User', pattern = 'StatuslineTestUpdate' } },
    },
  },
})
statusline.render()
assert(cached_calls == 0)
visible = true
statusline.render()
statusline.render()
assert(cached_calls == 1)
highlight = 'Error'
assert(statusline.render():find('%#Error#', 1, true))
assert(cached_calls == 1)
vim.api.nvim_eval_statusline(vim.o.statusline, { winid = original, maxwidth = vim.o.columns })
assert(cached_calls == 2)
vim.api.nvim_exec_autocmds('User', { pattern = 'StatuslineTestUpdate' })
statusline.render()
assert(cached_calls == 3)
vim.api.nvim_eval_statusline(vim.o.statusline, { winid = original, maxwidth = vim.o.columns })
assert(cached_calls == 4)
vim.api.nvim_win_set_buf(current, target_buffer)
statusline.render()
assert(cached_calls == 5)
visible = false
assert(not statusline.render():find('%#Error#', 1, true))

print('Statusline checks passed')
