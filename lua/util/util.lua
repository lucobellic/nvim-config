local M = {}
-- Check if a file is a gp.nvim file type
---@param file_name string?
function M.is_gp_file(file_name)
  local regex = '%d*-%d*-%d*.%d*-%d*-%d*.%d*.md'
  return file_name and file_name:match(regex)
end

function M.open_file()
  -- Find the first open window with a valid buffer
  local buffers = vim.tbl_filter(
    function(buffer) return #buffer.windows >= 1 end,
    vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })
  )
  local first_window = #buffers > 0 and buffers[1].windows[1] or nil

  -- Open file under cursor in first valid window or in new window otherwise
  local filename = vim.fn.findfile(vim.fn.expand('<cfile>'))
  if vim.fn.filereadable(filename) == 1 then
    if first_window then
      vim.api.nvim_set_current_win(first_window)
    end
    vim.cmd('edit ' .. filename)
  else
    vim.notify('File does not exist: ' .. filename)
  end
end

return M
