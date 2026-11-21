---@class User.Statuscolumn.Line
---@field sign? table
---@field git? table
---@field gutter? vim.api.keyset.highlight Background and underline set by diff ribbons
---@field text? string

---@class User.Statuscolumn.Selection
---@field first integer
---@field last integer
---@field first_from_start boolean The first selected line starts at its first character
---@field rest_from_start boolean The other selected lines start at their first character
---@field gutter vim.api.keyset.highlight

---@class User.Statuscolumn.Window
---@field first integer
---@field last integer
---@field lines table<integer, User.Statuscolumn.Line>
---@field hidden boolean
---@field signs boolean
---@field numbers boolean
---@field cursor? integer
---@field background? integer
---@field selection? User.Statuscolumn.Selection

---@class User.Statuscolumn
local M = {}

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

---@param group string
---@param gutter vim.api.keyset.highlight
---@return string
local function get_gutter_highlight(group, gutter)
  local redraw_key = group .. ':' .. vim.inspect(gutter)
  if redraw_highlights[redraw_key] then
    return redraw_highlights[redraw_key]
  end

  local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
  local key = group .. vim.inspect(highlight) .. vim.inspect(gutter)
  if not cursor_sign_highlights[key] then
    next_cursor_sign_highlight = next_cursor_sign_highlight + 1
    local name = 'StatusColumnGutter' .. next_cursor_sign_highlight
    cursor_sign_highlights[key] = name
    vim.api.nvim_set_hl(0, name, vim.tbl_extend('force', highlight, gutter))
  end
  redraw_highlights[redraw_key] = cursor_sign_highlights[key]
  return redraw_highlights[redraw_key]
end

---@param extmark table?
---@param cursor_background integer?
---@param gutter vim.api.keyset.highlight?
---@param reset string Highlight that follows the sign
---@return string
local format_extmark = function(extmark, cursor_background, gutter, reset)
  if not extmark or not extmark[4] or not extmark[4].sign_text or extmark[4].sign_text == '' then
    return ' '
  end

  if extmark[4].sign_text:match('^%s+$') then
    return ' '
  end

  if extmark[4].sign_hl_group then
    local highlight = gutter and get_gutter_highlight(extmark[4].sign_hl_group, gutter)
      or get_cursor_sign_highlight(extmark[4].sign_hl_group, cursor_background)
    return ('%%#%s#%s'):format(highlight, extmark[4].sign_text):gsub('%s*$', '') .. reset
  end

  return extmark[4].sign_text
end

---@param win integer
---@return integer?
local function ribbon_namespace(win)
  local namespace = vim.api.nvim_get_namespaces()['diff-ribbon.decorations']
  if not namespace or not vim.list_contains(vim.api.nvim__ns_get(namespace).wins or {}, win) then
    return nil
  end
  return namespace
end

--- Diff ribbons color the gutter of changed lines, so the band runs unbroken from the ribbon to the text.
---@param state User.Statuscolumn.Window
---@param win integer
---@param buf integer
local function collect_gutter(state, win, buf)
  local namespace = vim.g.diff_ribbon and ribbon_namespace(win)
  if not namespace then
    return
  end
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    namespace,
    { state.first - 1, 0 },
    { state.last - 1, -1 },
    { details = true }
  )
  vim.iter(extmarks):each(function(extmark)
    local group = extmark[4].number_hl_group
    if group then
      local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
      local row = extmark[2] + 1
      state.lines[row] = state.lines[row] or {}
      state.lines[row].gutter = { bg = highlight.bg, underline = highlight.underline, sp = highlight.sp }
    end
  end)
end

--- The order of two getpos() positions in the buffer.
---@param left integer[]
---@param right integer[]
---@return boolean
local function is_before(left, right) return left[2] < right[2] or (left[2] == right[2] and left[3] < right[3]) end

--- Only the bounds are read so the cost stays the same for huge selections.
---@param win integer
---@return User.Statuscolumn.Selection?
local function collect_selection(win)
  local mode = vim.fn.mode()
  if not (mode == 'v' or mode == 'V' or mode == '\22') or win ~= vim.api.nvim_get_current_win() then
    return nil
  end
  local anchor, cursor = vim.fn.getpos('v'), vim.fn.getpos('.')
  local first, last = anchor, cursor
  if is_before(cursor, anchor) then
    first, last = cursor, anchor
  end
  local selection = {
    first = first[2],
    last = last[2],
    first_from_start = mode == 'V' or first[3] == 1,
    rest_from_start = true,
    gutter = { bg = vim.api.nvim_get_hl(0, { name = 'Visual', link = false }).bg },
  }
  if mode == '\22' then
    local left = math.min(vim.fn.virtcol('v', true)[1], vim.fn.virtcol('.', true)[1])
    selection.first_from_start = left == 1
    selection.rest_from_start = left == 1
  end
  return selection
end

--- The gutter joins the selection only when the line is selected from its first character.
---@param selection User.Statuscolumn.Selection?
---@param line integer
---@return boolean
local function is_selected_from_start(selection, line)
  if not selection or line < selection.first or line > selection.last then
    return false
  end
  return line == selection.first and selection.first_from_start or line > selection.first and selection.rest_from_start
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
    selection = collect_selection(win),
  }
  windows[win] = state
  if state.hidden then
    return state
  end
  collect_gutter(state, win, buf)
  if not state.signs then
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

---@public
---@return string
function M.render()
  if vim.v.virtnum < 0 then
    return ''
  end

  local line = vim.v.lnum
  local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  local state = get_window(win, line)
  if state.hidden then
    return ''
  end

  -- While selecting, the selection alone decides the gutter color.
  local is_cursor_line = state.cursor == line and not state.selection
  local idle_highlight = (state.cursor == line and state.selection) and '%#LineNr#' or ''
  local entry = state.lines[line]
  local ribbon = entry and entry.gutter
  local gutter = is_selected_from_start(state.selection, line) and state.selection.gutter or ribbon
  local gutter_highlight = gutter
    and ('%#' .. get_gutter_highlight(is_cursor_line and 'CursorLineNr' or 'LineNr', gutter) .. '#')

  -- Only display line numbers when signcolumn is 'no'
  if not state.signs then
    return (state.numbers and vim.v.virtnum == 0) and ((gutter_highlight or '') .. '%l ') or ''
  end

  local signs = '  '
  if entry then
    if not entry.text then
      local background = is_cursor_line and state.background or nil
      local reset = gutter_highlight or '%*'
      entry.text = format_extmark(entry.sign, background, gutter, reset)
        .. format_extmark(entry.git, background, gutter, reset)
    end
    signs = entry.text
  end
  -- Changed lines sit outside diff folds, so a blank keeps the fold column from breaking the gutter color.
  local fold_column = (vim.v.virtnum == 0 and not ribbon) and '%C ' or '  '
  local cursor_highlight = gutter_highlight or (is_cursor_line and '%#CursorLineNr#' or idle_highlight)
  local trailing_highlight = gutter_highlight or (is_cursor_line and '%#CursorLineNr#' or '%#FoldColumn#')
  return cursor_highlight .. signs .. '%=%l' .. fold_column .. trailing_highlight
end

---@public
function M.setup()
  clear_redraw_cache()
  cursor_sign_highlights = {}
  redrawing = false
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
    group = vim.api.nvim_create_augroup('UserStatuscolumn', { clear = true }),
    ---@param _ vim.api.keyset.create_autocmd.callback_args
    callback = function(_)
      cursor_sign_highlights = {}
      clear_redraw_cache()
    end,
  })
  vim.o.statuscolumn = "%!v:lua.require'statuscolumn'.render()"
end

return M
