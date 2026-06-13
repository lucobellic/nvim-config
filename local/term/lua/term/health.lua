local M = {}

---@private
---@param name string
---@return boolean
local function check_executable(name) return vim.fn.executable(name) == 1 end

M.check = function()
  vim.health.start('term plugin')

  -- Check nui.nvim dependency
  local ok, _ = pcall(require, 'nui.popup')
  if ok then
    vim.health.ok('nui.nvim is installed')
  else
    vim.health.error('nui.nvim is not installed; term plugin requires it as a dependency')
  end

  -- Check nui.utils.autocmd
  ok, _ = pcall(require, 'nui.utils.autocmd')
  if ok then
    vim.health.ok('nui.utils.autocmd is available')
  else
    vim.health.error('nui.utils.autocmd is not available')
  end

  -- Check editor wrapper script exists and is executable
  local wrapper_path = vim.fn.stdpath('config') .. '/local/term/lua/term/editor-wrapper.sh'
  local stat = vim.uv.fs_stat(wrapper_path)
  if stat then
    vim.health.ok('editor-wrapper.sh found at: ' .. wrapper_path)
    -- Check executable bit for owner
    local is_executable = bit.band(stat.mode, tonumber('100', 8)) ~= 0
    if is_executable then
      vim.health.ok('editor-wrapper.sh is executable')
    else
      vim.health.warn('editor-wrapper.sh is not executable; run: chmod +x ' .. wrapper_path)
    end
  else
    vim.health.error('editor-wrapper.sh not found at: ' .. wrapper_path)
  end

  -- Check shell
  local shell = vim.o.shell
  if shell and shell ~= '' then
    if check_executable(shell) then
      vim.health.ok('shell is set and executable: ' .. shell)
    else
      vim.health.warn('shell is set but may not be executable: ' .. shell)
    end
  else
    vim.health.warn('vim.o.shell is not set')
  end

  -- Check core module can load
  ok, _ = pcall(require, 'term.core')
  if ok then
    vim.health.ok('term.core loads successfully')
  else
    vim.health.error('term.core failed to load')
  end

  -- Check term module can load
  ok, _ = pcall(require, 'term.term')
  if ok then
    vim.health.ok('term.term loads successfully')
  else
    vim.health.error('term.term failed to load')
  end

  -- Check for common named terminal executables
  local named = {
    { 'lazygit', 'lazygit' },
    { 'yazi', 'yazi' },
    { 'lazydocker', 'lazydash' },
    { 'ranger', 'ranger' },
  }

  for _, item in ipairs(named) do
    local exec_name, term_name = item[1], item[2]
    if check_executable(exec_name) then
      vim.health.ok(string.format('"%s" executable found for terminal "%s"', exec_name, term_name))
    else
      vim.health.warn(string.format('"%s" executable not found; terminal "%s" will fail', exec_name, term_name))
    end
  end
end

return M
