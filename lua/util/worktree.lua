---@class Util.Worktree
local M = {}

---@class Util.Worktree.Item: snacks.picker.Item
---@field path string
---@field branch string

---Parse one block of `git worktree list --porcelain`
---@param block string
---@return Util.Worktree.Item?
local function parse_worktree(block)
  local path = block:match('^worktree ([^\n]+)')
  -- Bare repositories have no files to edit.
  if not path or block:find('\nbare') then
    return nil
  end
  local branch = block:match('\nbranch refs/heads/([^\n]+)') or 'detached'
  return { text = branch .. ' ' .. path, path = path, branch = branch }
end

---List the worktrees of the repository in the current directory
---@return Util.Worktree.Item[]
local function list_worktrees()
  local result = vim.system({ 'git', 'worktree', 'list', '--porcelain' }, { text = true }):wait()
  if result.code ~= 0 then
    return {}
  end
  return vim.iter(vim.split(result.stdout or '', '\n\n', { trimempty = true })):map(parse_worktree):totable()
end

---@param item Util.Worktree.Item
---@return snacks.picker.Highlight[]
local function format_worktree(item)
  return {
    { item.branch, 'SnacksPickerGitBranch' },
    { ' ' },
    { vim.fn.fnamemodify(item.path, ':~'), 'SnacksPickerDir' },
  }
end

---@param picker snacks.Picker
---@param item Util.Worktree.Item?
local function open_worktree(picker, item)
  picker:close()
  if item then
    vim.schedule(function() require('util.persistence').open_directory(item.path) end)
  end
end

---Use Snacks picker to switch to the session of a git worktree
---@public
---@return nil
function M.select_worktree()
  local worktrees = list_worktrees()
  if #worktrees == 0 then
    vim.notify('No git worktrees found', vim.log.levels.WARN, { title = 'Worktree' })
    return
  end

  Snacks.picker.pick({
    title = 'Find Worktree',
    layout = { preset = 'telescope_no_preview' },
    items = worktrees,
    format = format_worktree,
    confirm = open_worktree,
  })
end

return M
