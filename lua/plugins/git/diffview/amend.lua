---@class Plugins.Git.Diffview.Amend
local M = {}

---@class Plugins.Git.Diffview.Amend.GitOptions
---@field env? table<string, string>
---@field stdin? string

---@param arguments string[]
---@param cwd string
---@param options? Plugins.Git.Diffview.Amend.GitOptions
---@return vim.SystemCompleted
local function await_git(arguments, cwd, options)
  local thread = assert(coroutine.running())
  options = options or {}

  ---@param result vim.SystemCompleted
  local function on_exit(result)
    vim.schedule(function()
      local ok, message = coroutine.resume(thread, result)
      if not ok then
        vim.notify(message, vim.log.levels.ERROR)
      end
    end)
  end

  vim.system(
    vim.list_extend({ 'git' }, arguments),
    { cwd = cwd, env = options.env, stdin = options.stdin, text = true },
    on_exit
  )

  return coroutine.yield()
end

---@param action string
---@param result vim.SystemCompleted
---@return string
local function git_failure(action, result)
  local details = vim.trim(result.stderr or result.stdout or '')
  if details == '' then
    details = 'Git exited with code ' .. result.code
  end
  return action .. ': ' .. details
end

---@param commit_hash string
---@param path string
---@param cwd string
---@return string? failure
local function perform_amend(commit_hash, path, cwd)
  local result = await_git({ 'merge-base', '--is-ancestor', commit_hash, 'HEAD' }, cwd)
  if result.code ~= 0 then
    return 'The selected commit is not an ancestor of HEAD'
  end

  result = await_git({ 'rev-parse', '--verify', commit_hash .. '^2' }, cwd)
  if result.code == 0 then
    return 'Amending merge commits is not supported'
  end

  result = await_git({ 'diff', '--cached', '--quiet', '--', path }, cwd)
  if result.code == 0 then
    return 'The selected file has no staged changes'
  elseif result.code ~= 1 then
    return git_failure('Could not inspect the staged file', result)
  end

  local staged_diff = await_git({ 'diff', '--cached', '--binary', '--no-ext-diff', '--', path }, cwd)
  if staged_diff.code ~= 0 then
    return git_failure('Could not read the staged change', staged_diff)
  end

  local temporary_index = vim.fn.tempname() .. '-diffview-index'
  local index_environment = { GIT_INDEX_FILE = temporary_index }

  result = await_git({ 'read-tree', 'HEAD' }, cwd, { env = index_environment })
  if result.code == 0 then
    result = await_git(
      { 'apply', '--cached', '--whitespace=nowarn' },
      cwd,
      { env = index_environment, stdin = staged_diff.stdout }
    )
  end
  if result.code == 0 then
    result = await_git({ 'commit', '--fixup=' .. commit_hash }, cwd, { env = index_environment })
  end
  vim.uv.fs_unlink(temporary_index)

  if result.code ~= 0 then
    return git_failure('Could not create the amended commit', result)
  end

  local rebase_arguments = {
    '-c',
    'sequence.editor=true',
    'rebase',
    '--interactive',
    '--autosquash',
    '--autostash',
    '--rebase-merges',
  }
  local parent = await_git({ 'rev-parse', '--verify', commit_hash .. '^' }, cwd)
  table.insert(rebase_arguments, parent.code == 0 and commit_hash .. '^' or '--root')

  result = await_git(rebase_arguments, cwd)
  if result.code ~= 0 then
    return git_failure('Could not rewrite the commit history', result)
  end
end

---@param commit_hash string
---@param path string
---@param cwd string
local function amend(commit_hash, path, cwd)
  vim.notify('Amending commit ' .. commit_hash, vim.log.levels.INFO)

  local thread = coroutine.create(function()
    local failure = perform_amend(commit_hash, path, cwd)
    if failure then
      vim.notify(failure, vim.log.levels.ERROR)
      return
    end

    vim.notify('Amended commit ' .. commit_hash, vim.log.levels.INFO)
    require('diffview.actions').refresh_files({ force = true })
  end)
  local ok, message = coroutine.resume(thread)
  if not ok then
    vim.notify(message, vim.log.levels.ERROR)
  end
end

---Amend the selected file-history commit with this file's staged change.
---@public
function M.under_cursor()
  local lazy = require('diffview.lazy')
  ---@type FileHistoryView|LazyModule
  local FileHistoryView = lazy.access('diffview.scene.views.file_history.file_history_view', 'FileHistoryView')
  local view = require('diffview.lib').get_current_view()
  if not (view and view:instanceof(FileHistoryView.__get())) then
    vim.notify('This action is only available in Diffview file history', vim.log.levels.WARN)
    return
  end

  ---@cast view FileHistoryView
  local file = view:infer_cur_file()
  local entry = view.panel:get_log_entry_at_cursor()
  if not file then
    vim.notify('No file selected in Diffview file history', vim.log.levels.WARN)
    return
  elseif not (entry and entry.commit and entry.commit.hash) then
    vim.notify('No commit selected in Diffview file history', vim.log.levels.WARN)
    return
  end

  amend(entry.commit.hash, file.absolute_path, view.adapter.ctx.toplevel)
end

return M
