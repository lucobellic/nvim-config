return {
  'aaronhallaert/advanced-git-search.nvim',
  cmd = { 'AdvancedGitSearch' },
  opts = {
    diff_plugin = 'diffview',
  },
  config = function(_, opts) require('advanced_git_search.snacks').setup(opts) end,
  dev = true,
}
