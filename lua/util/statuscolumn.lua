local Ui = require('lazyvim.util').ui

local M = {}

---@param sign? Sign
function M.icon(sign)
  sign = sign or {}
  local text = sign.text or ' '
  return sign.texthl and ('%#' .. sign.texthl .. '#' .. sign.text):gsub('%s*$', '') .. '%*' or text
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

function M.statuscolumn2()
  local icon = { text = ' ' }
  local git = { text = ' ' }
  local fold = { text = ' ' }

  -- Only show signs in non virtual or wrapped lines with sign column
  local win = vim.g.statusline_winid
  local show_signs = vim.wo[win].signcolumn ~= 'no' and vim.v.virtnum == 0
  if show_signs then
    local buf = vim.api.nvim_win_get_buf(win)
    for _, s in ipairs(Ui.get_signs(buf, vim.v.lnum)) do
      if s.name and (s.name:find('GitSign')) then
        git = s
      else
        icon = s
      end
    end

    vim.api.nvim_win_call(win, function()
      if vim.fn.foldclosed(vim.v.lnum) >= 0 then
        fold = { text = '', texthl = 'folded' }
      end
    end)

    local numbers = get_numbers(win)
    return table.concat({ M.icon(icon), M.icon(git), numbers, M.icon(fold) .. ' ' }, '')
  end

  return ''
end

function M.statuscolumn()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ''
  local show_signs = vim.wo[win].signcolumn ~= 'no'

  local components = { '', '', '' } -- left, middle, right

  if show_signs then
    ---@type Sign?,Sign?,Sign?
    local left, right, fold
    for _, s in ipairs(Ui.get_signs(buf, vim.v.lnum)) do
      local is_diagnostic = s.name and s.name:find('DiagnosticSign')
      if s.name and (s.name:find('GitSign')) then
        right = s
      elseif not is_diagnostic then
        left = s
      end
    end
    if vim.v.virtnum ~= 0 then
      left = nil
    end
    vim.api.nvim_win_call(win, function()
      if vim.fn.foldclosed(vim.v.lnum) >= 0 then
        fold = { text = vim.opt.fillchars:get().foldclose or '', texthl = 'Folded' }
      end
    end)
    -- Left: mark or non-git sign
    components[1] = Ui.icon(Ui.get_mark(buf, vim.v.lnum) or left)
    components[1] = components[1] == '' and ' ' or components[1]
    -- Right: fold icon or git sign (only if file)
    components[3] = is_file and Ui.icon(fold or right) or ''
  end

  -- Numbers in Neovim are weird
  -- They show when either number or relativenumber is true
  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.v.relnum == 0 then
      components[2] = is_num and '%l' or '%r' -- the current line
    else
      components[2] = is_relnum and '%r' or '%l' -- other lines
    end
    components[2] = '%=' .. components[2] .. ' ' -- right align
  end

  if vim.v.virtnum ~= 0 then
    components[2] = '%= '
  end

  return table.concat(components, '')
end

function M.get() return M.statuscolumn2() end

return M
