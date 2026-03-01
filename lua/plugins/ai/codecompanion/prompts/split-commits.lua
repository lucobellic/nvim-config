return {
  get_context = function()
    local current_branch = vim.fn.system('git rev-parse --abbrev-ref HEAD')
    local logs = vim.fn.system('git log --pretty=format:"%s%n%b" -n 50')
    local commit_history = 'Commit history for branch ' .. current_branch .. ':\n' .. logs .. '\n\n'
    local staged_changes = 'Staged files:\n' .. vim.fn.system('git diff --cached --name-only')
    return '<prompt>' .. commit_history .. staged_changes .. '</prompt> \n\n'
  end,
}
