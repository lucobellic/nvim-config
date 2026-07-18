local M = {}

---@class plugins.git.diffview.MergeCandidate
---@field hash string
---@field parents string[]

---@param result vim.SystemCompleted
local function notify_merge_error(result)
  local message = vim.trim(result.stderr or '')
  vim.notify('Unable to find branch merge' .. (message ~= '' and ': ' .. message or ''), vim.log.levels.ERROR)
end

---@param toplevel string Git repository root
---@param merge string Merge commit hash
---@param parent string Merge commit's first-parent hash
local function open_merge_history(toplevel, merge, parent)
  local view = require('diffview.lib').file_history(nil, {
    '-C=' .. toplevel,
    '--range=' .. parent .. '..' .. merge,
  })
  if view then
    view:open()
  end
end

--- Find the first merge that introduced `commit` into HEAD's first-parent history.
--- A candidate qualifies when the commit is absent from its first parent and present in a side parent.
---@param commit string
---@param toplevel string
---@param candidates plugins.git.diffview.MergeCandidate[]
---@param index integer Candidate index
---@param parent_index integer Parent currently being checked
local function inspect_merge_candidate(commit, toplevel, candidates, index, parent_index)
  local candidate = candidates[index]
  if not candidate then
    vim.notify('No containing merge found on HEAD first-parent history', vim.log.levels.INFO)
    return
  end

  local parent = candidate.parents[parent_index]
  if not parent then
    inspect_merge_candidate(commit, toplevel, candidates, index + 1, 1)
    return
  end

  vim.system({ 'git', 'merge-base', '--is-ancestor', commit, parent }, { cwd = toplevel }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        if parent_index == 1 then
          inspect_merge_candidate(commit, toplevel, candidates, index + 1, 1)
        else
          open_merge_history(toplevel, candidate.hash, candidate.parents[1])
        end
      elseif result.code == 1 then
        inspect_merge_candidate(commit, toplevel, candidates, index, parent_index + 1)
      else
        notify_merge_error(result)
      end
    end)
  end)
end

---@param output string Output from `git rev-list --parents`
---@return plugins.git.diffview.MergeCandidate[]
local function parse_merge_candidates(output)
  return vim
    .iter(vim.split(vim.trim(output), '\n', { trimempty = true }))
    :map(function(line)
      local parts = vim.split(line, '%s+')
      return { hash = parts[1], parents = { unpack(parts, 2) } }
    end)
    :totable()
end

--- Open the complete commit range for the merge containing the file-history commit under the cursor.
local function open_containing_merge_history()
  local view = require('diffview.lib').get_current_view()
  local item = view and view.panel:get_item_at_cursor()
  local commit = item and item.commit
  local toplevel = view and view.adapter.ctx.toplevel

  if not (commit and commit.hash and toplevel) then
    vim.notify('No commit under cursor', vim.log.levels.WARN)
    return
  end

  vim.system({ 'git', 'rev-list', '--parents', '-n', '1', commit.hash }, { cwd = toplevel }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        notify_merge_error(result)
        return
      end

      local selected = vim.split(vim.trim(result.stdout), '%s+')
      if #selected > 2 then
        open_merge_history(toplevel, selected[1], selected[2])
        return
      end

      vim.system(
        { 'git', 'rev-list', '--first-parent', '--merges', '--parents', 'HEAD' },
        { cwd = toplevel },
        function(merges)
          vim.schedule(function()
            if merges.code ~= 0 then
              notify_merge_error(merges)
              return
            end

            inspect_merge_candidate(commit.hash, toplevel, parse_merge_candidates(merges.stdout), 1, 1)
          end)
        end
      )
    end)
  end)
end

M.open_containing_merge_history = open_containing_merge_history

return M
