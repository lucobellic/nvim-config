local events = require('statusline.events')
local statusline = require('statusline')
local theme = require('statusline.theme')

---@class User.Statusline.Components
local M = {}

---Treat plugin output as text unless it explicitly provides a native format.
---@param text string
---@param group string
---@return string
local function styled(text, group) return statusline.highlight(statusline.escape(text), group, 'UserStatuslineBase') end

---@param mode string
---@param group string
---@return string
local function separator(mode, group) return styled(mode == 'n' and ' ' or '┃', group) end

---@public
---@param context User.Statusline.Context
---@return string
function M.left(context)
  local primary, secondary, mode = theme.groups()
  local parts = { styled('  ', primary) }
  local git = vim.b[context.bufnr].gitsigns_status_dict
  if git and git.head then
    local text = ' ' .. git.head .. ' '
    if #text > 20 then
      text = text:sub(1, 20) .. '...'
    end
    parts[#parts + 1] = styled(text, primary)
  end

  local lazy = package.loaded['lazy.status']
  if lazy and lazy.has_updates() then
    parts[#parts + 1] = styled(lazy.updates(), primary)
  end
  parts[#parts + 1] = separator(mode, secondary)

  local dap = package.loaded.dap
  if dap and dap.session() then
    parts[#parts + 1] = styled('  ' .. dap.status(), primary)
  end
  local recording = vim.fn.reg_recording()
  if recording ~= '' and vim.o.cmdheight == 0 then
    parts[#parts + 1] = styled(' ' .. recording, 'UserStatuslineMacro')
  end
  return table.concat(parts)
end

---@public
---@param _ User.Statusline.Context
---@return string
function M.center(_)
  local layout = package.loaded.layout
  if vim.g.layout ~= 'layout' or not layout then
    return ''
  end
  return table.concat(layout.get_statusline('bottom'))
end

---@return string
local function tasks()
  local overseer = package.loaded.overseer
  if not overseer then
    return ''
  end
  ---@type table<string, integer>
  local counts = {}
  vim.iter(overseer.list_tasks({ unique = true })):each(
    ---@param task overseer.Task
    function(task) counts[task.status] = (counts[task.status] or 0) + 1 end
  )
  local parts = {}
  vim
    .iter({
      { 'PENDING', ' ' },
      { 'RUNNING', ' ' },
      { 'SUCCESS', ' ' },
      { 'CANCELED', ' ' },
      { 'FAILURE', ' ' },
    })
    :each(
      ---@param entry string[]
      function(entry)
        local count = counts[entry[1]]
        if count then
          parts[#parts + 1] = styled(entry[2] .. count, 'UserStatuslineTask' .. entry[1]) .. ' '
        end
      end
    )
  return table.concat(parts)
end

---@return string
local function search_count()
  if vim.v.hlsearch == 0 or vim.o.cmdheight ~= 0 then
    return ''
  end
  local ok, search = pcall(vim.fn.searchcount)
  if not ok or not search.total then
    return ''
  end
  return ('[%d/%d] '):format(search.current, math.min(search.total, search.maxcount))
end

---@public
---@param context User.Statusline.Context
---@return string
function M.right(context)
  local primary, secondary, mode = theme.groups()
  local progress = package.loaded['lsp-progress']
  local lsp = ''
  if progress then
    -- The progress formatter reads the current buffer for its client list.
    lsp = vim.api.nvim_win_call(
      context.winid,
      ---@return string
      function() return progress.progress() .. ' ' end
    )
  end
  local search = vim.api.nvim_win_call(context.winid, search_count)
  return tasks()
    .. styled(lsp, secondary)
    .. styled(events.codecompanion(), secondary)
    .. styled(search, secondary)
    .. separator(mode, secondary)
    .. styled('  ' .. os.date('%Hh%M') .. ' ', primary)
end

return M
