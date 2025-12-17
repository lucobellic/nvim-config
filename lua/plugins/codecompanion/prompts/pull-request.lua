return {
  diff = function()
    local main_diff = vim.fn.system('git diff $(git merge-base HEAD main)...HEAD')
    local develop_diff = vim.fn.system('git diff $(git merge-base HEAD develop)...HEAD')
    return main_diff .. develop_diff
  end,
}
