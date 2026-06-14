local M = {}

---@return boolean
local function has_visible_overseer_output()
  return vim.iter(vim.api.nvim_tabpage_list_wins(0)):any(function(win)
    local bufnr = vim.api.nvim_win_get_buf(win)
    return vim.b[bufnr].overseer_task ~= nil
  end)
end

function M.close_list_if_no_output()
  local window = require('overseer.window')
  if not window.is_open() then
    return
  end
  if not has_visible_overseer_output() then
    require('overseer').close()
  end
end

function M.close_list_if_empty()
  local task_list = require('overseer.task_list')
  if #task_list.list_tasks({}) == 0 then
    local window = require('overseer.window')
    if window.is_open() then
      require('overseer').close()
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('OverseerAutoCloseList', { clear = true })

  vim.api.nvim_create_autocmd('BufWinLeave', {
    group = group,
    callback = function(args)
      if vim.b[args.buf].overseer_task then
        vim.schedule(function() M.close_list_if_no_output() end)
      end
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'OverseerListUpdate',
    callback = function()
      vim.schedule(function() M.close_list_if_empty() end)
    end,
  })
end

return M
