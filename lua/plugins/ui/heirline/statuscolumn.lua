local nes_namespace = vim.api.nvim_create_namespace('copilot_nes')
local cursor_tab_sign_namespace = vim.api.nvim_create_namespace('cursor-tab.nvim.sign')
local git_sign_namespace = vim.api.nvim_create_namespace('gitsigns_signs_')
local git_sign_staged_namespace = vim.api.nvim_create_namespace('gitsigns_signs_staged')

---@type table<string, string>
local cursor_sign_highlights = {}
local next_cursor_sign_highlight = 0

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function() cursor_sign_highlights = {} end,
})

---@param sign_group string
---@param background integer?
---@return string
local function get_cursor_sign_highlight(sign_group, background)
  if not background then
    return sign_group
  end

  local sign_highlight = vim.api.nvim_get_hl(0, { name = sign_group })
  if not sign_highlight.bg or sign_highlight.bg == background then
    return sign_group
  end

  local key = sign_group .. vim.inspect(sign_highlight) .. background
  if not cursor_sign_highlights[key] then
    next_cursor_sign_highlight = next_cursor_sign_highlight + 1
    local name = 'StatusColumnCursorSign' .. next_cursor_sign_highlight
    cursor_sign_highlights[key] = name
    vim.api.nvim_set_hl(0, name, vim.tbl_extend('force', sign_highlight, { bg = background }))
  end
  return cursor_sign_highlights[key]
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

---@param extmarks table[]
---@return table?
local function get_first_extmark(extmarks)
  if extmarks and #extmarks > 0 then
    table.sort(extmarks, function(a, b) return (a[4].priority or 0) > (b[4].priority or 0) end)
    return extmarks[1]
  end
  return nil
end

---@param text string
---@param buf integer
---@param line integer
---@return string
local function add_copilot_highlight(text, buf, line)
  local nes_signs = vim.api.nvim_buf_get_extmarks(buf, nes_namespace, { line, 0 }, { line, 0 }, { type = 'sign' })
  return #nes_signs > 0 and '%#CopilotNesDiffAdd#' .. text or text
end

---@param buf integer
---@param line integer
---@param cursor_background integer?
---@return string
local function get_git_sign(buf, line, cursor_background)
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    git_sign_namespace,
    { line, 0 },
    { line, 0 },
    { details = true, type = 'sign' }
  )
  if #extmarks == 0 then
    extmarks = vim.api.nvim_buf_get_extmarks(
      buf,
      git_sign_staged_namespace,
      { line, 0 },
      { line, 0 },
      { details = true, type = 'sign' }
    )
  end
  return format_extmark(get_first_extmark(extmarks), cursor_background)
end

---@param buf integer
---@param line integer
---@param cursor_background integer?
---@return string
local function get_sign(buf, line, cursor_background)
  local cursor_tab_signs = vim.api.nvim_buf_get_extmarks(
    buf,
    cursor_tab_sign_namespace,
    { line, 0 },
    { line, 0 },
    { details = true, type = 'sign' }
  )
  if #cursor_tab_signs > 0 then
    return format_extmark(get_first_extmark(cursor_tab_signs), cursor_background)
  end

  local extmarks = vim.api.nvim_buf_get_extmarks(buf, -1, { line, 0 }, { line, 0 }, { details = true, type = 'sign' })
  extmarks = vim
    .iter(extmarks or {})
    :filter(
      function(extmark)
        return extmark[4].ns_id ~= cursor_tab_sign_namespace
          and extmark[4].ns_id ~= git_sign_namespace
          and extmark[4].ns_id ~= git_sign_staged_namespace
      end
    )
    :totable()
  return format_extmark(get_first_extmark(extmarks), cursor_background)
end

local statuscolumn = {
  condition = function() return vim.bo.buftype ~= 'nofile' end,
  provider = function()
    if vim.bo.buftype == 'nofile' then
      return ''
    end

    if vim.g.zen_mode then
      return ''
    end

    if vim.v.virtnum < 0 then
      return ''
    end

    -- Only display line numbers when signcolumn is 'no'
    if vim.opt_local.signcolumn:get() == 'no' then
      local show_line_number = vim.opt_local.number:get() or vim.opt_local.relativenumber:get()
      return (show_line_number and vim.v.virtnum == 0) and '%l ' or ''
    end

    local line = vim.v.lnum - 1
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local is_cursor_line = vim.wo[win].cursorline and vim.api.nvim_win_get_cursor(win)[1] == vim.v.lnum
    local cursor_background = is_cursor_line and vim.api.nvim_get_hl(0, { name = 'CursorLineNr' }).bg or nil
    local sign = get_sign(buf, line, cursor_background)
    local git_sign = get_git_sign(buf, line, cursor_background)
    local fold_column = vim.v.virtnum == 0 and '%C' or ' '
    local cursor_highlight = is_cursor_line and '%#CursorLineNr#' or ''
    local trailing_highlight = is_cursor_line and '' or '%#FoldColumn#'
    local text = cursor_highlight .. sign .. git_sign .. '%l' .. fold_column .. trailing_highlight .. ' '
    return text
    -- return add_copilot_highlight(text, buf, line)
  end,
}

return statuscolumn
