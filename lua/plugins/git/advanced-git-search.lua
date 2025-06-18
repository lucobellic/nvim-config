return {
  'lucobellic/advanced-git-search.nvim',
  branch = 'feature/snacks_picker',
  cmd = { 'AdvancedGitSearch' },
  opts = {
    diff_plugin = 'diffview',
  },
  config = function(_, opts) require('advanced_git_search.snacks').setup(opts) end,
  dev = true,
}
