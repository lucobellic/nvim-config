local M = {}

--- Check if a buffer is open in another tab
--- @param current_buffer number
function M.is_buffer_in_an_other_tab(current_buffer)
  local current_tabpage = vim.api.nvim_get_current_tabpage()
  return vim
    .iter(require('scope.core').cache or {})
    :enumerate()
    :filter(function(tab, _) return tab ~= current_tabpage end)
    :map(function(_, buffers) return buffers end)
    :flatten()
    :any(function(buffer) return buffer == current_buffer end)
end

function M.scope_close_buffer(buffer)
  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end

  local window = vim.fn.bufwinid(buffer)

  -- Get all buflisted buffers except the one being closed
  local other_buffers = vim
    .iter(vim.fn.getbufinfo({ buflisted = 1 }) or {})
    :map(function(buf_info) return buf_info.bufnr end)
    :filter(function(bufnr) return bufnr ~= buffer end)
    :totable()

  -- Check if this buffer is displayed in any window
  local is_displayed = window ~= -1 and vim.api.nvim_win_is_valid(window)

  -- If buffer is displayed and there are no other buflisted buffers, notify and abort
  if is_displayed and #other_buffers == 0 then
    vim.notify('This is the last buffer and cannot be closed', vim.log.levels.INFO)
    return
  end

  -- If buffer is displayed, switch to another buffer first
  if is_displayed then
    -- Use bprevious to switch to the previous buffer in the buffer list
    vim.api.nvim_win_call(window, function() vim.cmd('bprevious') end)
  end

  -- Unlist the buffer and delete it if not in another tab
  if vim.api.nvim_buf_is_valid(buffer) then
    vim.api.nvim_set_option_value('buflisted', false, { buf = buffer })
    if not M.is_buffer_in_an_other_tab(buffer) then
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
  end
end

return M
