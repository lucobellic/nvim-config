local shared = require('plugins.ui.statusline.components.shared')
local statusline = require('statusline')

---@type User.Statusline.Component
local tasks = {
  ---@param _ User.Statusline.Context
  ---@return boolean
  condition = function(_) return package.loaded.overseer ~= nil end,
  ---@param _ User.Statusline.Context
  ---@return string
  provider = function(_)
    ---@type table<string, integer>
    local counts = {}
    vim.iter(package.loaded.overseer.list_tasks({ unique = true })):each(
      ---@param task overseer.Task
      function(task) counts[task.status] = (counts[task.status] or 0) + 1 end
    )
    local parts = {}
    vim.iter(shared.task_symbols):each(
      ---@param entry string[]
      function(entry)
        local count = counts[entry[1]]
        if count then
          parts[#parts + 1] = statusline.highlight(
            entry[2] .. count,
            'UserStatuslineTask' .. entry[1],
            'UserStatuslineBase'
          ) .. ' '
        end
      end
    )
    return table.concat(parts)
  end,
  format = true,
  update = { { event = 'User', pattern = { 'OverseerListUpdate', 'LazyLoad' } } },
}

---@type User.Statusline.Component
local lsp_progress = {
  ---@param _ User.Statusline.Context
  ---@return boolean
  condition = function(_) return package.loaded['lsp-progress'] ~= nil end,
  ---@param context User.Statusline.Context
  ---@return string
  provider = function(context)
    return vim.api.nvim_win_call(
      context.winid,
      ---@return string
      function() return package.loaded['lsp-progress'].progress() .. ' ' end
    )
  end,
  hl = shared.secondary,
  update = {
    'LspAttach',
    'LspDetach',
    { event = 'User', pattern = { 'LspProgressStatusUpdated', 'LazyLoad' } },
  },
}

---@type User.Statusline.Component
local codecompanion = {
  ---@param _ User.Statusline.Context
  ---@return string
  provider = function(_) return (shared.requests > 0 and shared.frames[shared.frame] or '') .. '  ' end,
  hl = shared.secondary,
}

---@type User.Statusline.Component
local search_count = {
  ---@param _ User.Statusline.Context
  ---@return boolean
  condition = function(_) return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0 end,
  ---@param context User.Statusline.Context
  ---@return string
  provider = function(context)
    return vim.api.nvim_win_call(
      context.winid,
      ---@return string
      function()
        local ok, search = pcall(vim.fn.searchcount, { recompute = false })
        if not ok or not search.total then
          return ''
        end
        return ('[%d/%d] '):format(search.current, math.min(search.total, search.maxcount))
      end
    )
  end,
  hl = shared.secondary,
}

---@type User.Statusline.Component
local separator = { provider = shared.separator, hl = shared.secondary }

---@type User.Statusline.Component
local clock = {
  ---@param _ User.Statusline.Context
  ---@return string
  provider = function(_) return '  ' .. os.date('%Hh%M') .. ' ' end,
  hl = shared.primary,
}

---@type User.Statusline.Component[]
local right = { tasks, lsp_progress, codecompanion, search_count, separator, clock }

return right
