---@class TermManagerUtil
local M = {}

--- Safely execute a function and notify on error
---@generic T
---@param fn fun(...): T
---@param ... any
---@return boolean ok
---@return T? result
function M.safe_call(fn, ...)
  local ok, result = pcall(fn, ...)
  if not ok then
    vim.notify('term: ' .. tostring(result), vim.log.levels.ERROR)
    return false, nil
  end
  return true, result
end

--- Safely execute an API call, optionally with a custom message prefix
---@generic T
---@param msg string Message prefix on failure
---@param fn fun(...): T
---@param ... any
---@return boolean ok
---@return T? result
function M.safe_api(msg, fn, ...)
  local ok, result = pcall(fn, ...)
  if not ok then
    vim.notify(msg .. ': ' .. tostring(result), vim.log.levels.ERROR)
    return false, nil
  end
  return true, result
end

--- Safely delete a buffer if it is valid
---@param bufnr integer
function M.safe_delete_buffer(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end
end

--- Clamp a number between min and max
---@param value number
---@param min number
---@param max number
---@return number
function M.clamp(value, min, max)
  if type(value) ~= 'number' or value ~= value then
    return min
  end
  return math.max(min, math.min(max, value))
end

return M
