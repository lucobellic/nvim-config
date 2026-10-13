---@class User.Statuscolumn.Line
---@field sign? table
---@field git? table
---@field text? string

---@class User.Statuscolumn.Window
---@field first integer
---@field last integer
---@field lines table<integer, User.Statuscolumn.Line>
---@field hidden boolean
---@field signs boolean
---@field numbers boolean
---@field cursor? integer
---@field background? integer

local cursor_tab_sign_namespace = vim.api.nvim_create_namespace('cursor-tab.nvim.sign')
local git_sign_namespace = vim.api.nvim_create_namespace('gitsigns_signs_')
local git_sign_staged_namespace = vim.api.nvim_create_namespace('gitsigns_signs_staged')

---@type table<integer, User.Statuscolumn.Window>
local windows = {}
---@type table<string, string>
local redraw_highlights = {}
---@type table<string, string>
local cursor_sign_highlights = {}
local next_cursor_sign_highlight = 0
local redrawing = false

-- Signs can change without a text edit or a cursor event.
---@type fun()
local function clear_redraw_cache()
  windows = {}
  redraw_highlights = {}
end

vim.api.nvim_set_decoration_provider(vim.api.nvim_create_namespace('user.statuscolumn'), {
  ---@param _ string
  ---@param _tick integer
  on_start = function(_, _tick)
    clear_redraw_cache()
    redrawing = true
  end,
  ---@param _ string
  ---@param _tick integer
  on_end = function(_, _tick)
    clear_redraw_cache()
    redrawing = false
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  ---@param _ vim.api.keyset.create_autocmd.callback_args
  callback = function(_)
    cursor_sign_highlights = {}
    clear_redraw_cache()
  end,
})

---@param sign_group string
---@param background integer?
---@return string
local function get_cursor_sign_highlight(sign_group, background)
  if not background then
    return sign_group
  end

  local redraw_key = sign_group .. ':' .. background
  if redraw_highlights[redraw_key] then
    return redraw_highlights[redraw_key]
  end

  local sign_highlight = vim.api.nvim_get_hl(0, { name = sign_group })
  if not sign_highlight.bg or sign_highlight.bg == background then
    redraw_highlights[redraw_key] = sign_group
    return sign_group
  end

  local key = sign_group .. vim.inspect(sign_highlight) .. background
  if not cursor_sign_highlights[key] then
    next_cursor_sign_highlight = next_cursor_sign_highlight + 1
    local name = 'StatusColumnCursorSign' .. next_cursor_sign_highlight
    cursor_sign_highlights[key] = name
    vim.api.nvim_set_hl(0, name, vim.tbl_extend('force', sign_highlight, { bg = background }))
  end
  redraw_highlights[redraw_key] = cursor_sign_highlights[key]
  return redraw_highlights[redraw_key]
end

---@param extmark table?
---@param cursor_background integer?
---@return string
local format_extmark = function(extmark, cursor_background)
  if not extmark or not extmark[4] or not extmark[4].sign_text or extmark[4].sign_text == '' then
    return ' '
  end

  if extmark[4].sign_text:match('^%s+$') then
    return ' '
  end

  if extmark[4].sign_hl_group then
    local highlight = get_cursor_sign_highlight(extmark[4].sign_hl_group, cursor_background)
    return ('%%#%s#%s'):format(highlight, extmark[4].sign_text):gsub('%s*$', '') .. '%*'
  end

  return extmark[4].sign_text
end

---@param candidate table
---@param current table?
---@param preferred_namespace integer
---@return boolean
local function prefer_sign(candidate, current, preferred_namespace)
  if not current then
    return true
  end
  local preferred = candidate[4].ns_id == preferred_namespace
  if preferred ~= (current[4].ns_id == preferred_namespace) then
    return preferred
  end
  return (candidate[4].priority or 0) > (current[4].priority or 0)
end

---@param win integer
---@param line integer
---@return User.Statuscolumn.Window
local function get_window(win, line)
  if not redrawing then
    clear_redraw_cache()
  end
  local cached = windows[win]
  if cached and line >= cached.first and line <= cached.last then
    return cached
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local options = vim.wo[win]
  ---@type User.Statuscolumn.Window
  local state = {
    first = math.min(vim.fn.line('w0', win), line),
    last = math.max(vim.fn.line('w$', win), line),
    lines = {},
    hidden = vim.bo[buf].buftype == 'nofile' or not not vim.g.zen_mode,
    signs = options.signcolumn ~= 'no',
    numbers = options.number or options.relativenumber,
    cursor = options.cursorline and vim.api.nvim_win_get_cursor(win)[1] or nil,
  }
  windows[win] = state
  if state.hidden or not state.signs then
    return state
  end
  state.background = state.cursor and vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }).bg or nil

  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { state.first - 1, 0 },
    { state.last - 1, -1 },
    { details = true, type = 'sign' }
  )
  ---@param extmark table
  local function collect_sign(extmark)
    local row = extmark[2] + 1
    local entry = state.lines[row] or {}
    state.lines[row] = entry
    local namespace = extmark[4].ns_id
    if namespace == git_sign_namespace or namespace == git_sign_staged_namespace then
      if prefer_sign(extmark, entry.git, git_sign_namespace) then
        entry.git = extmark
      end
    elseif prefer_sign(extmark, entry.sign, cursor_tab_sign_namespace) then
      entry.sign = extmark
    end
  end
  vim.iter(extmarks):each(collect_sign)
  return state
end

local statuscolumn = {
  ---@return string
  provider = function()
    if vim.v.virtnum < 0 then
      return ''
    end

    local line = vim.v.lnum
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local state = get_window(win, line)
    if state.hidden then
      return ''
    end

    -- Only display line numbers when signcolumn is 'no'
    if not state.signs then
      return (state.numbers and vim.v.virtnum == 0) and '%l ' or ''
    end

    local is_cursor_line = state.cursor == line
    local entry = state.lines[line]
    local signs = '  '
    if entry then
      if not entry.text then
        local background = is_cursor_line and state.background or nil
        entry.text = format_extmark(entry.sign, background) .. format_extmark(entry.git, background)
      end
      signs = entry.text
    end
    local fold_column = vim.v.virtnum == 0 and '%C ' or '  '
    local cursor_highlight = is_cursor_line and '%#CursorLineNr#' or ''
    local trailing_highlight = is_cursor_line and '%#CursorLineNr#' or '%#FoldColumn#'
    return cursor_highlight .. signs .. '%=%l' .. fold_column .. trailing_highlight
  end,
}

return statuscolumn
