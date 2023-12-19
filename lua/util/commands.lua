local M = {}

---Convert string valid command name with title case
---@param str string
---@return string
local function command_title_case(str)
  -- Replace special character with spaces and convert to title case
  ---@diagnostic disable-next-line
  return str
    :gsub('%W', ' ')
    :gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
    :gsub('%s+', '')
end

---Create user command from keymap
---@param command_name string
---@param keymap table<string, any>
local function create_command_from_keymap(command_name, keymap)
  local cmd = vim.api.nvim_replace_termcodes(keymap.lhs, true, false, true)
  vim.api.nvim_create_user_command(
    command_name,
    function() vim.api.nvim_feedkeys(cmd, 't', true) end,
    { desc = keymap.desc }
  )
end

---Create command from keymaps
---Iterate over all keymaps and create command for description
---only if command does not already exist
function M.create_command_from_keymaps()
  local keymaps = vim.api.nvim_get_keymap('n')
  local keymaps_with_desc = vim.tbl_filter(function(keymap) return keymap.desc ~= nil end, keymaps)
  for _, keymap in ipairs(keymaps_with_desc or {}) do
    local command_name = command_title_case(keymap.desc)
    if vim.fn.exists(':' .. command_name) == 0 then
      create_command_from_keymap(command_name, keymap)
    end
  end
end

return M
