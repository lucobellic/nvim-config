local M = {}

---@param result vim.SystemCompleted
local function notify_merge_error(result)
  local message = vim.trim(result.stderr or '')
  vim.notify('Unable to find branch merge' .. (message ~= '' and ': ' .. message or ''), vim.log.levels.ERROR)
end

--- Focus a commit after Diffview's asynchronous history load.
---@param view FileHistoryView
---@param focus_commit string
---@param focus_path? string
local function focus_file_history_commit_on_load(view, focus_commit, focus_path)
  local panel = view.panel
  if not panel or type(panel.update_entries) ~= 'function' then
    return
  end

  local update_entries = panel.update_entries
  rawset(panel, 'update_entries', function(self, callback)
    rawset(self, 'update_entries', nil)
    return update_entries(self, function(entries, status, ...)
      if status == 1 and entries then
        local target = vim
          .iter(entries)
          :filter(function(entry)
            local hash = entry.commit and entry.commit.hash
            return hash
              and (
                hash == focus_commit
                or hash:sub(1, #focus_commit) == focus_commit
                or focus_commit:sub(1, #hash) == hash
              )
          end)
          :map(function(entry)
            if focus_path then
              local matching_file = vim.iter(entry.files or {}):find(
                function(file) return file.path and vim.fs.normalize(file.path) == vim.fs.normalize(focus_path) end
              )
              if matching_file then
                return matching_file
              end
            end
            return entry.files and entry.files[1]
          end)
          :next()

        if target and type(view.set_file) == 'function' then
          view:set_file(target)
        elseif not target then
          vim.notify('Selected commit was not loaded in file history', vim.log.levels.WARN)
        end
      end
      if callback then
        callback(entries, status, ...)
      end
    end)
  end)
end

---@param toplevel string Git repository root
---@param merge string Merge commit hash
---@param parent string Merge commit's first-parent hash
---@param focus_commit? string
local function open_merge_history(toplevel, merge, parent, focus_commit)
  local view = require('diffview.lib').file_history(nil, {
    '-C=' .. toplevel,
    '--range=' .. parent .. '..' .. merge,
  })
  if view then
    if focus_commit then
      focus_file_history_commit_on_load(view, focus_commit)
    end
    view:open()
  end
end

--- Find the first HEAD merge that introduced `commit` through a side parent.
---@param commit string
---@param toplevel string
local function find_containing_merge(commit, toplevel)
  vim.system(
    { 'git', 'rev-list', '--merges', '--ancestry-path', commit .. '..HEAD' },
    { cwd = toplevel },
    function(descendants)
      vim.schedule(function()
        if descendants.code ~= 0 then
          notify_merge_error(descendants)
          return
        end

        local descendant_merges = {}
        for _, hash in ipairs(vim.split(descendants.stdout or '', '%s+', { trimempty = true })) do
          descendant_merges[hash] = true
        end

        vim.system(
          { 'git', 'rev-list', '--parents', '--first-parent', '--merges', '--reverse', 'HEAD' },
          { cwd = toplevel },
          function(first_parent_merges)
            vim.schedule(function()
              if first_parent_merges.code ~= 0 then
                notify_merge_error(first_parent_merges)
                return
              end

              local candidate = vim
                .iter(vim.split(first_parent_merges.stdout or '', '\n', { trimempty = true }))
                :map(function(line) return vim.split(line, '%s+') end)
                :filter(function(parts) return descendant_merges[parts[1]] end)
                :next()

              if not candidate or #candidate < 3 then
                vim.notify('No containing merge found on HEAD first-parent history', vim.log.levels.INFO)
                return
              end

              vim.system(
                { 'git', 'merge-base', '--is-ancestor', commit, candidate[2] },
                { cwd = toplevel },
                function(first_parent)
                  vim.schedule(function()
                    if first_parent.code == 1 then
                      open_merge_history(toplevel, candidate[1], candidate[2], commit)
                    elseif first_parent.code == 0 then
                      vim.notify('No containing merge found on HEAD first-parent history', vim.log.levels.INFO)
                    else
                      notify_merge_error(first_parent)
                    end
                  end)
                end
              )
            end)
          end
        )
      end)
    end
  )
end

---@param commit string
---@param toplevel string
local function inspect_selected_commit(commit, toplevel)
  vim.system({ 'git', 'rev-list', '--parents', '-n', '1', commit }, { cwd = toplevel }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        notify_merge_error(result)
        return
      end

      local selected = vim.split(vim.trim(result.stdout), '%s+')
      if #selected > 2 then
        open_merge_history(toplevel, selected[1], selected[2], commit)
        return
      end

      find_containing_merge(commit, toplevel)
    end)
  end)
end

--- Open the complete commit range for the merge containing a commit.
---@param commit? string
---@param toplevel? string Git repository root
local function open_containing_merge_history(commit, toplevel)
  if not (commit and toplevel) then
    local view = require('diffview.lib').get_current_view()
    local item = view and view.panel:get_item_at_cursor()
    commit = item and item.commit and item.commit.hash
    toplevel = view and view.adapter.ctx.toplevel
  end

  if not (commit and toplevel) then
    vim.notify('No commit under cursor', vim.log.levels.WARN)
    return
  end

  inspect_selected_commit(commit, toplevel)
end

M.focus_file_history_commit_on_load = focus_file_history_commit_on_load
M.open_containing_merge_history = open_containing_merge_history

return M
