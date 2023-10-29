local Ui = require('lazyvim.util').ui

local M = {}

function M.get()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local components = { "", "", "" } -- left, middle, right

  if show_signs then
    ---@type Sign?,Sign?,Sign?
    local left, right, fold
    for _, s in ipairs(Ui.get_signs(buf, vim.v.lnum)) do
      if s.name and s.name:find("GitSign") then
        right = s
      else
        left = s
      end
    end
    if vim.v.virtnum ~= 0 then
      left = nil
    end
    vim.api.nvim_win_call(win, function()
      if vim.fn.foldclosed(vim.v.lnum) >= 0 then
        fold = { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded" }
      end
    end)

    -- Left: mark or non-git sign
    local left_icon = Ui.icon(Ui.get_mark(buf, vim.v.lnum) or left)
    -- local left_icon = Ui.icon(Ui.get_mark(buf, vim.v.lnum) or left):gsub("%s+", "")
    -- left_icon = left_icon == '' and ' ' or left_icon
    components[1] = left_icon

    -- Right: fold icon or git sign (only if file)
    local right_icon = Ui.icon(fold or right):gsub("%s+", "")
    right_icon = right_icon == '' and ' ' or right_icon
    components[3] = is_file and right_icon or ""
  end

  -- Numbers in Neovim are weird
  -- They show when either number or relativenumber is true
  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.v.relnum == 0 then
      components[2] = is_num and "%l" or "%r" -- the current line
    else
      components[2] = is_relnum and "%r" or "%l" -- other lines
    end
    components[2] = "%=" .. components[2] .. " " -- right align
  end

  local statusline = table.concat(components, "")
  return statusline
end

return M
