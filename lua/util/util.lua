local M = {}
-- Check if a file is a gp.nvim file type
---@param file_name string?
function M.is_gp_file(file_name) return file_name and file_name:match('%d*-%d*-%d*.%d*-%d*-%d*.%d*') end
return M
