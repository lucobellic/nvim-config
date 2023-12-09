local M = {}

---Convert string valid command name with title case
---@param str string
---@return string
local function command_title_case(str)
  -- Replace special charactes with spaces and convert to title case
  ---@diagnostic disable-next-line
  return str
    :gsub('%W', ' ')
    :gsub("(%a)([%w_']*)", function(first, rest)
      return first:upper() .. rest:lower()
    end)
    :gsub('%s+', '')
end

--- Create command from keymaps
--- Iterate over all keymaps and create command for description
--- only if command does not already exist
function M.create_command_from_keymaps()
  local keymaps = vim.api.nvim_get_keymap('n')
  for _, value in ipairs(keymaps or {}) do
    if value.desc then
      local command_name = command_title_case(value.desc)
      if vim.fn.exists(':' .. command_name) == 0 then
        vim.api.nvim_create_user_command(command_name, function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(value.lhs, true, false, true), 't', true)
        end, { desc = value.desc })
      end
    end
  end
end

return M
