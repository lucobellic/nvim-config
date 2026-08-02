return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = { spec = { { '<leader>gg', mode = { 'n', 'x', 'v' }, group = 'gitanuki' } } },
  },
  {
    'lucobellic/gitanuki.nvim',
    dev = true,
    lazy = false,
    enabled = true,
    keys = function()
      local gitanuki = require('gitanuki')
      local merge_request = gitanuki.merge_request
      local review = gitanuki.review

      return {
        -- Navigation
        {
          ']t',
          review.next_thread,
          repeatable = { ['.'] = review.next_thread, [';'] = review.next_thread, [','] = review.prev_thread },
          desc = 'Gitanuki Next review thread',
        },
        {
          '[t',
          review.prev_thread,
          repeatable = { ['.'] = review.prev_thread, [';'] = review.next_thread, [','] = review.prev_thread },
          desc = 'Gitanuki Previous review thread',
        },
        {
          ']u',
          review.next_unviewed,
          repeatable = { ['.'] = review.next_unviewed, [';'] = review.next_unviewed, [','] = review.prev_unviewed },
          desc = 'Gitanuki Next unviewed file',
        },
        {
          '[u',
          review.prev_unviewed,
          repeatable = { ['.'] = review.prev_unviewed, [';'] = review.next_unviewed, [','] = review.prev_unviewed },
          desc = 'Gitanuki Previous unviewed file',
        },
        -- Standard keymaps
        { '<leader>ggr', review.open, desc = 'Gitanuki Review' },
        { '<leader>ggl', merge_request.list, desc = 'Gitanuki List MR' },
        { '<leader>ggR', review.reload, desc = 'Gitanuki Reload review' },
        { '<leader>ggv', review.toggle_viewed, desc = 'Gitanuki Toggle viewed file' },
        { '<leader>ggC', review.toggle_comments, desc = 'Gitanuki Toggle review comments' },
        { '<leader>ggc', review.comments, desc = 'Gitanuki Review comments' },
        { '<leader>ggt', review.timeline, desc = 'Gitanuki Review timeline' },
        { '<leader>ggp', review.preview_thread, desc = 'Gitanuki Preview review thread' },
        { '<leader>ggn', review.new_comment, desc = 'Gitanuki New review comment' },
        { '<leader>ggi', review.inline_comment, mode = { 'n', 'x', 'v' }, desc = 'Gitanuki New inline comment' },
        { '<leader>ggs', review.new_suggestion, mode = { 'n', 'x', 'v' }, desc = 'Gitanuki Suggest change' },
        { '<leader>gga', review.apply_suggestion, desc = 'Gitanuki Apply suggestion' },
        { '<leader>ggA', review.apply_suggestions, desc = 'Gitanuki Apply all suggestions' },
        { '<leader>ggP', review.publish_drafts, desc = 'Gitanuki Publish all drafts' },
        { '<leader>ggx', review.toggle_resolved, desc = 'Gitanuki Resolve or reopen thread' },
        {
          '<C-r>',
          merge_request.reload,
          ft = 'gitanuki-merge-request',
          desc = 'Gitanuki Reload merge request',
        },
      }
    end,
    ---@type gitanuki.Config
    opts = {
      review = {
        composer = { mode = 'float' }, -- "float", "split", or "current"
        annotations = {
          signs = {
            unresolved = '',
            resolved = '',
            draft = '',
          },
          virtual_text = false,
          virt_lines = true, -- render threaded review conversations below changed lines
          underline = false,
          mappings = false,
        },
      },
    },
  },
}
