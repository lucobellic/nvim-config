local M = {}

local language_extensions = {
  python = '.py',
  julia = '.jl',
  r = '.r',
  R = '.r',
  bash = '.sh',
}

-- Get the metadata from the ipynb file
---@param notebook_path string
---@return table
local function get_ipynb_metadata(notebook_path)
  local metadata = vim.json.decode(io.open(notebook_path, 'r'):read('a'))['metadata']
  local language = metadata.kernelspec.language
  return { language = language, extension = language_extensions[language] }
end

---@return boolean valid check if jupytext is installed
local function validate()
  -- Check if jupytext is installed
  if not vim.fn.executable('jupytext') then
    vim.notify('jupytext is not installed', vim.log.levels.ERROR, { title = 'jupytext' })
    return false
  end

  return true
end

M.pair = function()
  local notebook_path = vim.fn.resolve(vim.fn.expand('%'))
  if validate() then
    if not vim.fn.filereadable(notebook_path) then
      vim.notify('No notebook found: ' .. notebook_path, vim.log.levels.ERROR, { title = 'jupytext' })
      return false
    end

    if vim.fn.fnamemodify(notebook_path, ':e') ~= 'ipynb' then
      vim.notify('Not an notebook file: ' .. notebook_path, vim.log.levels.ERROR, { title = 'jupytext' })
      return false
    end

    local jupytext_pair_cmd = 'jupytext --set-formats ipynb,auto:hydrogen ' .. notebook_path
    local pair_cmd_output = vim.fn.system(jupytext_pair_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify(pair_cmd_output, vim.log.levels.ERROR, { title = 'jupytext' })
      return
    end
  end
end

M.sync = function()
  local current_path = vim.fn.resolve(vim.fn.expand('%'))
  local jupytext_sync_cmd = 'jupytext --sync ' .. current_path

  local sync_cmd_output = vim.fn.system(jupytext_sync_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(sync_cmd_output, vim.log.levels.ERROR, { title = 'jupytext' })
    return
  end
end

return M
