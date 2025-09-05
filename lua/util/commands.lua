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

--- Create autocommand to track recently visited files
--- Update the global variable `vim.g.visited_files`
function M.track_visited_files()
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('snacks_recent_files', { clear = true }),
    callback = function(args)
      local file = args.file
      if file == '' or vim.bo[args.buf].buftype ~= '' then
        return
      end

      file = vim.fs.normalize(vim.fn.fnamemodify(file, ':p'), { _fast = true, expand_env = false })

      --- Clear entry to be re-added at the front
      local visited_files = vim.g.VISITEDFILES or {}
      if vim.tbl_contains(visited_files, file) then
        visited_files = vim.tbl_filter(function(f) return f ~= file end, visited_files)
      end
      table.insert(visited_files, 1, file)

      if #visited_files > 100 then
        visited_files[101] = nil
      end

      vim.g.VISITEDFILES = visited_files
    end,
  })
end

return M
