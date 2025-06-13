return {
  'lucobellic/gitlab.nvim',
  enabled = not vim.g.started_by_firenvim and vim.env.INSIDE_DOCKER ~= nil,
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    { 'lucobellic/diffview.nvim', branch = 'personal' },
    'stevearc/dressing.nvim', -- Recommended but not required. Better UI for pickers.
    'nvim-tree/nvim-web-devicons', -- Recommended but not required. Icons in discussion tree.
    {
      'folke/which-key.nvim',
      optional = true,
      opts = {
        spec = {
          { '<leader>gl', group = 'gitlab' },
          { '<leader>gla', group = 'assignee' },
          { '<leader>glr', group = 'reviewer' },
          { '<leader>gll', group = 'label' },
        },
      },
    },
  },
  keys = {
    { '<leader>gl', false },
    { '<leader>glb', function() require('gitlab').choose_merge_request() end, desc = 'Gitlab Choose Merge Request' },
    { '<leader>glS', function() require('gitlab').review() end, desc = 'Gitlab Start Review' },
    { '<leader>gls', function() require('gitlab').summary() end, desc = 'Gitlab Summary' },
    { '<leader>glA', function() require('gitlab').approve() end, desc = 'Gitlab Approve' },
    { '<leader>glR', function() require('gitlab').revoke() end, desc = 'Gitlab Revoke' },
    { '<leader>glc', function() require('gitlab').create_comment() end, desc = 'Gitlab Create Comment' },
    {
      '<leader>glc',
      function() require('gitlab').create_multiline_comment() end,
      desc = 'Gitlab Create Multiline Comment',
      mode = { 'n', 'v' },
    },
    {
      '<leader>glC',
      function() require('gitlab').create_comment_suggestion() end,
      desc = 'Gitlab Create Comment Suggestion',
      mode = { 'n', 'v' },
    },
    { '<leader>glO', function() require('gitlab').create_mr() end, desc = 'Gitlab Create Mr' },
    {
      '<leader>glm',
      function() require('gitlab').move_to_discussion_tree_from_diagnostic() end,
      desc = 'Gitlab Move To Discussion Tree From Diagnostic',
    },
    { '<leader>gln', function() require('gitlab').create_note() end, desc = 'Gitlab Create Note' },
    { '<leader>gld', function() require('gitlab').toggle_discussions() end, desc = 'Gitlab Toggle Discussions' },
    { '<leader>glaa', function() require('gitlab').add_assignee() end, desc = 'Gitlab Add Assignee' },
    { '<leader>glad', function() require('gitlab').delete_assignee() end, desc = 'Gitlab Delete Assignee' },
    { '<leader>glla', function() require('gitlab').add_label() end, desc = 'Gitlab Add Label' },
    { '<leader>glld', function() require('gitlab').delete_label() end, desc = 'Gitlab Delete Label' },
    { '<leader>glra', function() require('gitlab').add_reviewer() end, desc = 'Gitlab Add Reviewer' },
    { '<leader>glrd', function() require('gitlab').delete_reviewer() end, desc = 'Gitlab Delete Reviewer' },
    { '<leader>glp', function() require('gitlab').pipeline() end, desc = 'Gitlab Pipeline' },
    { '<leader>glo', function() require('gitlab').open_in_browser() end, desc = 'Gitlab Open In Browser' },
    { '<leader>glM', function() require('gitlab').merge() end, desc = 'Gitlab Merge' },
    { '<leader>glu', function() require('gitlab').copy_mr_url() end, desc = 'Gitlab Copy Mr Url' },
    { '<leader>glP', function() require('gitlab').publish_all_drafts() end, desc = 'Gitlab Publish All Drafts' },
    { '<leader>glD', function() require('gitlab').toggle_draft_mode() end, desc = 'Gitlab Toggle Draft Mode' },
  },
  build = function() require('gitlab.server').build(true) end, -- Builds the Go binary
  --- @type Settings
  --- @diagnostic disable-next-line: missing-fields
  opts = {
    discussion_tree = {
      position = 'bottom',
      resolved = '󱍧',
      unresolved = '󱍮',
      toggle_node = 'l',
      draft = '',
      draft_mode = true,
    },
    discussion_sign_and_diagnostic = {
      skip_resolved_discussion = true,
    },
    keymaps = {
      global = { disable_all = true },
      popup = { -- The popup for comment creation, editing, and replying
        discard_changes = '<Esc>',
        perform_action = '<c-cr>', -- Once in normal mode, does action (like saving comment or editing description, etc)
        perform_linewise_action = '<leader>l', -- Once in normal mode, does the linewise action (see logs for this job, etc)
      },
    },
    discussion_signs = {
      icons = {
        comment = '',
        range = '│',
      },
    },
    discussion_diagnostic = {
      display_opts = {
        underline = false,
      },
    },
    reviewer_settings = {
      diffview = {
        imply_local = true,
      },
    },
    pipeline = {
      failed = '',
      canceled = '',
      success = '',
    },
  },
}
