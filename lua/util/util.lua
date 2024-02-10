local M = {}
-- Check if a file is a gp.nvim file type
---@param file_name string?
function M.is_gp_file(file_name)
  local regex = '%d*-%d*-%d*.%d*-%d*-%d*.%d*.md'
  return file_name and file_name:match(regex)
end

return M
