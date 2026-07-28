---@class Lichtblick.FileModule
---@field read fun(path: string): string|nil, string|nil Read a file as binary data.
---@field write fun(path: string, content: string): boolean, string|nil Write binary data to a file.
---@field atomic_write fun(path: string, content: string): boolean, string|nil Atomically replace a file's contents.
---@type Lichtblick.FileModule
local M = {}

---Read an entire file without newline conversion.
---@param path string
---@return string|nil content
---@return string|nil error
function M.read(path)
  local file, err = io.open(path, 'rb')
  if not file then
    return nil, err
  end

  local content = file:read('*a')
  file:close()
  return content
end

---Write file contents and report write or close errors.
---@param path string
---@param content string
---@return boolean success
---@return string|nil error
function M.write(path, content)
  local file, err = io.open(path, 'wb')
  if not file then
    return false, err
  end

  local ok, write_err = file:write(content)
  local close_ok, close_err = file:close()
  if not ok then
    return false, write_err
  end
  if not close_ok then
    return false, close_err
  end
  return true
end

---Write through a temporary file before replacing the destination.
---@param path string
---@param content string
---@return boolean success
---@return string|nil error
function M.atomic_write(path, content)
  local temporary_path = ('%s.lichtblick.%s.tmp'):format(path, vim.uv.hrtime())
  local original_stat = vim.uv.fs_stat(path)
  local ok, err = M.write(temporary_path, content)
  if not ok then
    return false, err
  end

  if original_stat then
    local chmod_ok, chmod_err = vim.uv.fs_chmod(temporary_path, original_stat.mode)
    if not chmod_ok then
      vim.uv.fs_unlink(temporary_path)
      return false, chmod_err
    end
  end

  local rename_ok, rename_err = vim.uv.fs_rename(temporary_path, path)
  if not rename_ok then
    vim.uv.fs_unlink(temporary_path)
    return false, rename_err
  end
  return true
end

return M
