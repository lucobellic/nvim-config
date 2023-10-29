---@diagnostic disable: redundant-parameter

---@class TabUtil
local M = {}

---@enum tab_direction
local tab_direction = {
  next = 'next',
  prev = 'prev',
}

---Get all `buflisted` buffers
---@return number[] listed_buffers
function M.nvim_list_buflisted()
  local listed_buffers = {}
  for _, buffer in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_option(buffer, 'buflisted') then
      table.insert(listed_buffers, buffer)
    end
  end
  return listed_buffers
end

---Focus to the window with the first `buflisted` buffer in the current tab if any
function M.focus_first_listed_buffer()
  local listed_buffers = M.nvim_list_buflisted()
  local windows = vim.api.nvim_tabpage_list_wins(0)
  for _, window in pairs(windows) do
    local window_buffer = vim.api.nvim_win_get_buf(window)
    for _, listed_buffer in pairs(listed_buffers) do
      if window_buffer == listed_buffer then
        vim.api.nvim_set_current_win(window)
        return
      end
    end
  end
end

---@param list any[]
---@param item any
---@return any?
function M.find_first_different(list, item)
  for _, v in pairs(list) do
    if v ~= item then
      return v
    end
  end
end

---Move current buffer to the next or previous tabpage.
---Create a new tabpage if there is only one tabpage.
---@param direction tab_direction
function M.move_in_tab(direction)
  local buffer_to_move = vim.api.nvim_get_current_buf()
  local nb_tabpages = #vim.api.nvim_list_tabpages()
  local listed_buffers = M.nvim_list_buflisted()
  local nb_listed_buffers = #listed_buffers

  -- Do nothing if there is only one tabpage and one listed buffer
  if nb_tabpages == 1 and nb_listed_buffers == 1 then
    return
  end

  -- Hide buffer from the buffer line
  vim.api.nvim_buf_set_option(buffer_to_move, 'buflisted', false)

  -- Select the next buffer as active if any
  local next_buffer = M.find_first_different(listed_buffers, buffer_to_move)
  if next_buffer then
    vim.api.nvim_set_current_buf(next_buffer)
  end

  -- Close the tabpage if there is only one listed buffer
  if nb_listed_buffers == 1 then
    vim.cmd('tabclose')
    if direction == tab_direction.next then
      vim.cmd('tabnext')
    end
  elseif nb_tabpages == 1 then
    vim.cmd(direction == tab_direction.prev and '-tabnew' or 'tabnew')
  else
    vim.cmd(direction == tab_direction.prev and 'tabprevious' or 'tabnext')
  end

  -- Re-enable the buffer and focus it
  vim.api.nvim_buf_set_option(buffer_to_move, 'buflisted', true)
  vim.api.nvim_set_current_buf(buffer_to_move)
end

return M
