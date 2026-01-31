local nes_namespace = vim.api.nvim_create_namespace('copilot_nes')
local git_sign_namespace = vim.api.nvim_create_namespace('gitsigns_signs_')
local git_sign_staged_namespace = vim.api.nvim_create_namespace('gitsigns_signs_staged')

---@param extmark table?
---@return string
local format_extmark = function(extmark)
  if not extmark or not extmark[4] or not extmark[4].sign_text or extmark[4].sign_text == '' then
    return ' '
  end

  if extmark[4].sign_hl_group then
    return ('%%#%s#%s'):format(extmark[4].sign_hl_group, extmark[4].sign_text):gsub('%s*$', '') .. '%*'
  end

  return extmark[4].sign_text or ' '
end

---@param extmarks table[]
---@return table?
local function get_first_extmark(extmarks)
  table.sort(extmarks, function(a, b) return (a[4].priority or 0) < (b[4].priority or 0) end)
  return extmarks[1]
end

---@param text string
---@return string
local function add_copilot_highlight(text, buf, line)
  local nes_signs = vim.api.nvim_buf_get_extmarks(buf, nes_namespace, { line, 0 }, { line, 0 }, { type = 'sign' })
  return #nes_signs > 0 and '%#CopilotNesDiffAdd#' .. text or text
end

local function get_git_sign(buf, line)
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
  return format_extmark(get_first_extmark(extmarks))
end

local function get_sign(buf, line)
  local extmarks = vim.api.nvim_buf_get_extmarks(buf, -1, { line, 0 }, { line, 0 }, { details = true, type = 'sign' })
  extmarks = vim
    .iter(extmarks or {})
    :filter(
      function(extmark) return extmark[4].ns_id ~= git_sign_namespace and extmark[4].ns_id ~= git_sign_staged_namespace end
    )
    :totable()
  return format_extmark(get_first_extmark(extmarks))
end

local statuscolumn = {
  condition = function() return require('heirline.conditions').is_active() and vim.bo.buftype ~= 'nofile' end,
  provider = function()

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
    local sign = get_sign(buf, line)
    local git_sign = get_git_sign(buf, line)
    local text = sign .. git_sign .. '%l%C '
    return text
    -- return add_copilot_highlight(text, buf, line)
  end,
}

return statuscolumn
