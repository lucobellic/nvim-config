local symbol = '│'

if vim.g.vscode then
  local vscode = require('vscode')

  -- Navigation
  vim.keymap.set('n', '>h', function() vscode.action('workbench.action.editor.nextChange') end, { desc = 'Next Hunk' })
  vim.keymap.set('n', '>H', function() vscode.action('workbench.action.editor.nextChange') end, { desc = 'Next Hunk' })
  vim.keymap.set(
    'n',
    '<h',
    function() vscode.action('workbench.action.editor.previousChange') end,
    { desc = 'Prev Hunk' }
  )
  vim.keymap.set(
    'n',
    '<H',
    function() vscode.action('workbench.action.editor.previousChange') end,
    { desc = 'Prev Hunk' }
  )

  -- Staging

  -- NOTE: no keymap to stage current block
  -- vim.keymap.set('n', '<leader>hs', function() vscode.action('git.diff.stageHunk') end, { desc = 'Stage Block' })
  vim.keymap.set('v', '<leader>hs', function() vscode.action('git.stageSelectedRanges') end, { desc = 'Stage Hunk' })
  vim.keymap.set('n', '<leader>hS', function() vscode.action('git.stage') end, { desc = 'Stage All' })

  -- Reset
  vim.keymap.set(
    { 'n', 'v' },
    '<leader>hr',
    function() vscode.action('git.revertSelectedRanges') end,
    { desc = 'Reset Hunk' }
  )
  vim.keymap.set('n', '<leader>hR', function() vscode.action('git.unstage') end, { desc = 'Reset Buffer' })

  -- Visualization
  vim.keymap.set('n', '<leader>ub', function() vscode.action('gitlens.toggleReviewMode') end, { desc = 'Line Blame' })

  vim.keymap.set(
    { 'n', 'v' },
    '<leader>hv',
    function() vscode.action('editor.action.dirtydiff.next') end,
    { desc = 'Preview Hunk' }
  )
end

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = { { '<leader>h', group = 'hunk' }, { '<leader>ht', group = 'toggle' } },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    keys = {
      {
        '[h',
        function() require('gitsigns').nav_hunk('prev', { navigation_message = false }) end,
        repeatable = true,
        desc = 'Prev Hunk',
      },
      {
        '[H',
        function() require('gitsigns').nav_hunk('prev', { navigation_message = false }) end,
        repeatable = true,
        desc = 'Prev Hunk',
      },
      {
        ']h',
        function() require('gitsigns').nav_hunk('next', { navigation_message = false }) end,
        repeatable = true,
        desc = 'Next Hunk',
      },
      {
        ']H',
        function() require('gitsigns').nav_hunk('next', { navigation_message = false }) end,
        repeatable = true,
        desc = 'Next Hunk',
      },
      {
        '<leader>htb',
        function() require('gitsigns').toggle_current_line_blame() end,
        desc = 'Toggle Line Blame',
      },
      {
        '<leader>htw',
        function() require('gitsigns').toggle_word_diff() end,
        desc = 'Toggle Word Diff',
      },
    },
    opts = {
      signs = {
        add = { text = symbol },
        change = { text = symbol },
        delete = { text = symbol },
        topdelete = { text = symbol },
        changedelete = { text = symbol },
        untracked = { text = ' ' },
      },
      signs_staged = {
        add = { text = '┆' },
        change = { text = '┆' },
        delete = { text = '┆' },
        topdelete = { text = '┆' },
        changedelete = { text = '┆' },
        untracked = { text = ' ' },
      },

      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`

      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end
        -- Actions
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage Hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset Hunk' })
        map(
          'v',
          '<leader>hs',
          function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { desc = 'Stage Hunk' }
        )
        map(
          'v',
          '<leader>hr',
          function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { desc = 'Reset Hunk' }
        )
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'Buffer Stage' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo Stage Hunk' })
        map('n', '<leader>hU', gs.reset_buffer_index, { desc = 'Reset Buffer Index' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset Buffer' })
        map('n', '<leader>hv', gs.preview_hunk, { desc = 'Preview Hunk' })
        map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { desc = 'Line Blame' })
        map('n', '<leader>ub', gs.toggle_current_line_blame, { desc = 'Toggle Line Blame' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'Diff This' })
        map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'Diff This (cached)' })
        map('n', '<leader>hl', '<cmd>Gitsigns setloclist<cr>', { desc = 'Diff To Loc List' })

        -- Text object
        map({ 'o', 'x' }, 'ih', '<cmd><C-U>Gitsigns select_hunk<CR>')
      end,

      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      attach_to_untracked = true,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`

      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = true,
      },

      sign_priority = 10,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000,

      preview_config = {
        -- Options passed to nvim_open_win
        border = 'single',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
      },
    },
  },
}
