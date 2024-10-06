local M = {}

---@param sign? Sign
function M.icon(sign)
  sign = sign or {}
  local text = type(sign.text) == 'string' and sign.text or ' '
  return sign.texthl and ('%#' .. sign.texthl .. '#' .. text):gsub('%s*$', '') .. '%*' or text
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
  provider = function(self)
    local icon = { text = ' ' }
    local git = { text = ' ' }
    local fold = { text = ' ' }

    -- Only show signs in non virtual or wrapped lines with sign column
    local win = vim.api.nvim_get_current_win()
    local show_signs = vim.wo[win].signcolumn ~= 'no' and vim.v.virtnum == 0
    if show_signs then
      local buf = vim.api.nvim_win_get_buf(win)
      vim.iter(self.ui.get_signs(buf, vim.v.lnum)):each(function(sign)
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
