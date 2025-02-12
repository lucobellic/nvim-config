local conditions = require('heirline.conditions')

local M = {}

---@param sign? Sign
function M.icon(sign)
  sign = sign or {}
  local text = type(sign.text) == 'string' and sign.text or ' '
  text = text ~= '' and text or ' '
  return sign.texthl and ('%#' .. sign.texthl .. '#' .. text):gsub('%s*$', '') .. '%*' or text
end

---@alias Sign {name:string, text:string, texthl:string, priority:number}
-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[]
---@param buf number
---@param lnum number
function M.get_signs(buf, lnum)
  -- Get regular signs
  ---@type Sign[]
  local signs = {}
  if vim.fn.has('nvim-0.10') == 0 then
    -- Only needed for Neovim <0.10
    -- Newer versions include legacy signs in nvim_buf_get_extmarks
    for _, sign in ipairs(vim.fn.sign_getplaced(buf, { group = '*', lnum = lnum })[1].signs) do
      local ret = vim.fn.sign_getdefined(sign.name)[1] --[[@as Sign]]
      if ret then
        ret.priority = sign.priority
        signs[#signs + 1] = ret
      end
    end
  end
  -- Get extmark signs
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = 'sign' }
  )
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or extmark[4].sign_name or '',
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end
  -- Sort by priority
  table.sort(signs, function(a, b) return (a.priority or 0) < (b.priority or 0) end)
  return signs
end

local function get_numbers(win)
  local lines = '%='
  -- Numbers in Neovim are weird
  -- They show when either number or relativenumber is true
  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.v.relnum == 0 then
      lines = is_num and '%l' or '%r' -- the current line
    else
      lines = is_relnum and '%r' or '%l' -- other lines
    end
    lines = '%=' .. lines -- right align
  end

  return lines
end

local statuscolumn = {
  static = {
    ui = require('lazyvim.util').ui,
  },
  condition = conditions.is_active,
  provider = function(self)
    local icon = { text = ' ' }
    local git = { text = ' ' }
    local fold = { text = ' ' }

    local win = vim.api.nvim_get_current_win()
    local show_signs = vim.wo[win].signcolumn ~= 'no' and vim.v.virtnum == 0
    if show_signs then
      local buf = vim.api.nvim_win_get_buf(win)
      vim.iter(M.get_signs(buf, vim.v.lnum)):each(function(sign)
        if sign.name and (sign.name:find('GitSign')) then
          if not (sign.name:find('Staged') and git.name) then
            git = sign
          end
        else
          icon = sign
        end
      end)

      vim.api.nvim_win_call(win, function()
        if vim.fn.foldclosed(vim.v.lnum) >= 0 then
          fold = { text = '', texthl = 'Constant' }
        end
      end)

      local numbers = get_numbers(win)
      return table.concat({ M.icon(icon), M.icon(git), numbers, M.icon(fold) .. ' ' }, '')
    end

    return ''
  end,
}

return {
  fallthrough = false,
  statuscolumn,
}
