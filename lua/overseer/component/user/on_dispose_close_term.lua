---@type overseer.ComponentFileDefinition
local comp = {
  desc = 'Close terminal window when task is disposed',
  constructor = function()
    return {
      on_dispose = function(_, task)
        local bufnr = task:get_bufnr()
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        vim
          .iter(vim.api.nvim_list_wins())
          :filter(function(winid) return vim.api.nvim_win_get_buf(winid) == bufnr end)
          :each(function(winid) vim.api.nvim_win_close(winid, true) end)
      end,
    }
  end,
}

return comp
