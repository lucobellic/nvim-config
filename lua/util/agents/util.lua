local M = {}

--- Get all non floating valid windows displaying the given buffer
---@param bufnr integer
---@return integer[] list of window IDs
function M.buf_get_valid_wins(bufnr)
  local wins = vim.api.nvim_tabpage_list_wins(0)
  return vim.tbl_filter(
    function(win)
      return vim.api.nvim_win_is_valid(win)
        and vim.api.nvim_win_get_config(win).relative == ''
        and vim.api.nvim_win_get_buf(win) == bufnr
    end,
    wins
  )
end

return M
