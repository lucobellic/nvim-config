return {
  'harrisoncramer/gitlab.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
    'stevearc/dressing.nvim', -- Recommended but not required. Better UI for pickers.
    'nvim-tree/nvim-web-devicons', -- Recommended but not required. Icons in discussion tree.
    {
      'folke/which-key.nvim',
      optional = true,
      opts = {
        defaults = {
          ['<leader>gl'] = { name = 'gitlab' },
          ['<leader>gla'] = { name = 'assignee' },
        },
      },
    },
  },
  keys = {
    { '<leader>gll', function() require('gitlab').local_review() end, desc = 'Gitlab Local Review' },
    { '<leader>glr', function() require('gitlab').review() end, desc = 'Gitlab Review' },
    { '<leader>gls', function() require('gitlab').summary() end, desc = 'Gitlab Summary' },
    { '<leader>glA', function() require('gitlab').approve() end, desc = 'Gitlab Approve' },
    { '<leader>glR', function() require('gitlab').revoke() end, desc = 'Gitlab Revoke' },
    { '<leader>glc', function() require('gitlab').create_comment() end, desc = 'Gitlab Create Comment' },
    {
      '<leader>glc',
      function() require('gitlab').create_multiline_comment() end,
      desc = 'Gitlab Create Multiline Comment',
      mode = 'v',
    },
    {
      '<leader>glC',
      function() require('gitlab').create_comment_suggestion() end,
      desc = 'Gitlab Create Comment Suggestion',
      mode = 'v',
    },
    { '<leader>gln', function() require('gitlab').create_note() end, desc = 'Gitlab Create Note' },
    { '<leader>gld', function() require('gitlab').toggle_discussions() end, desc = 'Gitlab Toggle Discussions' },
    { '<leader>glad', function() require('gitlab').delete_assignee() end, desc = 'Gitlab Delete Assignee' },
    { '<leader>glaa', function() require('gitlab').add_assignee() end, desc = 'Gitlab Add Assignee' },
    -- { '<leader>glra', function()gitlab require('gitlab').add_reviewer() end, desc = 'Gitlab Add Reviewer' },
    -- { '<leader>glrd', function() require('gitlab').delete_reviewer() end, desc = 'Gitlab Delete Reviewer' },
    { '<leader>glp', function() require('gitlab').pipeline() end, desc = 'Gitlab Pipeline' },
    { '<leader>glo', function() require('gitlab').open_in_browser() end, desc = 'Gitlab Open In Browser' },
    { '<leader>glM', function() require('gitlab').merge() end, desc = 'Gitlab Merge' },
    {
      '<leader>glm',
      function() require('gitlab').move_to_discussion_tree_from_diagnostic() end,
      desc = 'Gitlab Move To Discussion Tree From Diagnostic',
    },
  },
  build = function() require('gitlab.server').build(true) end, -- Builds the Go binary
  opts = {
    discussion_tree = {
      position = 'bottom',
      resolved = '󱍧',
      unresolved = '󱍮',
      toggle_node = 'l',
    },
    discussion_sign = {
      text = '󱍫',
      culhl = 'DiagnosticInfo',
      texthl = 'DiagnosticInfo',
    },
  },
}
