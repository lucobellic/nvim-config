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

---@param opts? { path: string?, extension: string? }
M.pair = function(opts)
  local notebook_path = opts and type(opts.path) == 'string' and opts.path or vim.fn.resolve(vim.fn.expand('%'))
  if validate() then
    if vim.fn.filereadable(notebook_path) == 0 then
      vim.notify('No notebook found: ' .. notebook_path, vim.log.levels.ERROR, { title = 'jupytext' })
      return
    end

    if vim.fn.fnamemodify(notebook_path, ':e') ~= 'ipynb' then
      vim.notify('Not an notebook file: ' .. notebook_path, vim.log.levels.ERROR, { title = 'jupytext' })
      return
    end

    local extension = opts and type(opts.extension) == 'string' and opts.extension or 'py:percent'
    local jupytext_pair_cmd = 'jupytext --set-formats ipynb,' .. extension .. ' ' .. notebook_path
    local pair_cmd_output = vim.fn.system(jupytext_pair_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify(pair_cmd_output, vim.log.levels.ERROR, { title = 'jupytext' })
      return
    end

    local msg = 'Notebook paired: ' .. notebook_path
    vim.notify(msg, vim.log.levels.INFO, { title = 'jupytext' })
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

---@param path? string Path to the file to convert
M.to_notebook = function(path)
  local current_path = type(path) == 'string' and path or vim.fn.resolve(vim.fn.expand('%'))
  local jupytext_sync_cmd = 'jupytext --to ipynb ' .. current_path

  local sync_cmd_output = vim.fn.system(jupytext_sync_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(sync_cmd_output, vim.log.levels.ERROR, { title = 'jupytext' })
    return
  end
end

M.to_paired_notebook = function()
  local current_path = vim.fn.resolve(vim.fn.expand('%'))
  local extension = vim.fn.fnamemodify(current_path, ':e')
  local notebook_path = vim.fn.fnamemodify(current_path, ':r') .. '.ipynb'

  -- Only convert if the notebook file do not already exist
  if vim.fn.filereadable(notebook_path) == 0 then
    M.to_notebook(current_path)
  end

  M.pair({ path = notebook_path, extension = extension })
end

return M
