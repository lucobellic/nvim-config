if vim.g.vscode then
  local vscode = require('vscode')
  vim.notify = vscode.notify

  vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = false, silent = true })
  vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = false, silent = true })

  -- Format
  vim.keymap.set(
    'n',
    '<leader>=',
    function() vscode.action('editor.action.formatDocument') end,
    { desc = 'Format document' }
  )

  -- File Explorer
  vim.keymap.set(
    'n',
    '<leader>fe',
    function() vscode.action('workbench.explorer.fileView.focus') end,
    { desc = 'Focus file explorer' }
  )

  vim.keymap.set('n', '<leader>ub', function() vscode.action('gitlens.toggleReviewMode') end, { desc = 'Line Blame' })
end

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  keys = {

    ------------------
    -- Text Manipulation
    ------------------
    { mode = 'c', '<esc>', '<C-c>', desc = 'Exit insert mode' },
    { mode = 'v', '/', '"hy/<C-r>h', desc = 'Search word' },
    { mode = 'v', '<leader>rr', function() vim.fn.feedkeys(':s/', 't') end, desc = 'Replace Visual' },

    { '<leader>rr', function() vim.fn.feedkeys(':%s/', 't') end, desc = 'Replace' },
    {
      '<leader>rw',
      function() return ':%s/' .. vim.fn.expand('<cword>') .. '//g<left><left>' end,
      desc = 'Replace word under cursor',
      expr = true,
    },
    { mode = 'v', 'c', '<cmd>lua vim.g.change = true<cr>c', desc = 'Change' },
    { '<leader>A', '<cmd>silent %y+<cr>', desc = 'Copy all' },
    { mode = { 'n', 'v' }, '>>', '>>', remap = false, desc = 'Increase Indent' },
    { mode = { 'n', 'v' }, '<<', '<<', remap = false, desc = 'Decrease Indent' },

    ------------------
    -- Navigation
    ------------------
    { mode = { 'o', 'v', 'n' }, '>', ']', desc = 'Next', remap = true },
    { mode = { 'o', 'v', 'n' }, '<', '[', desc = 'Prev', remap = true },

    ------------------
    -- File Operations
    ------------------
    { mode = { 'v', 'n' }, '<C-s>', '<cmd>w<cr><esc>', desc = 'Save file' },

    ------------------
    -- Quit Commands
    ------------------
    { '<leader>qq', '<cmd>qa!<cr>', desc = 'Quit all' },
    { '<leader>qa', '<cmd>qa!<cr>', desc = 'Quit all' },
    {

      '<leader>qu',
      function()
        vim
          .iter(vim.api.nvim_list_uis())
          :filter(function(ui) return ui.chan and not ui.stdout_tty end)
          :each(function(ui) vim.fn.chanclose(ui.chan) end)
      end,
      noremap = true,
      desc = 'Quit UIs',
    },
    { 't', '<esc>', '<c-\\><c-n>', desc = 'Enter Normal Mode' },

    ------------------
    -- Tab Management
    ------------------
    { '<S-up>', '<cmd>tabnext<cr>', desc = 'Tab Next' },
    { '<S-down>', '<cmd>tabprev<cr>', desc = 'Tab Prev' },
    { '<C-t>', '<cmd>tabnew<cr>', desc = 'Tab New' },
    { 'gq', '<cmd>tabclose<cr>', desc = 'Tab Close' },
    { '<A-j>', function() require('util.tabpages').move_buffer_to_tab('prev', true) end },
    { '<A-k>', function() require('util.tabpages').move_buffer_to_tab('next', true) end },

    ------------------
    -- Jupytext
    ------------------
    { '<leader>njs', function() require('util.jupytext').sync() end, desc = 'Jupytext Sync' },
    { '<leader>njp', function() require('util.jupytext').pair() end, desc = 'Jupytext Pair' },
    { '<leader>njc', function() require('util.jupytext').to_notebook() end, desc = 'Jupytext Convert' },
    { '<leader>njl', function() require('util.jupytext').to_paired_notebook() end, desc = 'Jupytext Link' },
  },
}
