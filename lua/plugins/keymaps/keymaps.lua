--- Operator-pending paste: allows using motions/textobjects after `p` or `P`
--- Example: `piw` will paste over the inner word under the cursor
---@param type 'line'|'char'|'block'
function _G.custom_operator_paste(type)
  -- Ensure we have valid positions
  if vim.fn.getpos("'[")[2] == 0 or vim.fn.getpos("']")[2] == 0 then
    return
  end

  -- Select the text that was just operated on
  if type == 'line' then
    -- For line-wise operations, select the entire lines
    vim.cmd('normal! `[V`]')
  elseif type == 'block' then
    -- For block-wise operations, use block selection
    vim.cmd('normal! `[<C-v>`]')
  else
    -- Default to character-wise if type is unknown
    -- For character-wise operations, select the characters
    vim.cmd('normal! `[v`]')
  end

  -- Paste over the selection (this will replace the selected text)
  vim.cmd('normal! P')
end

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
  vim.keymap.set('n', '<leader>fe', function()
    if vscode.get_config('workbench.explorer.openEditors.visible') then
      if vscode.get_config('workbench.sideBar.location') == 'left' then
        vscode.action('workbench.action.toggleSidebarVisibility')
      elseif vscode.get_config('workbench.sideBar.location') == 'right' then
        vscode.action('workbench.action.toggleAuxiliaryBar')
      end
    else
      vscode.action('workbench.view.explorer')
    end
  end, { desc = 'Toggle file explorer' })

  vim.keymap.set('n', '<leader>ub', function() vscode.action('gitlens.toggleReviewMode') end, { desc = 'Line Blame' })

  -- Search and navigation
  vim.keymap.set('n', '<leader><space>', '<cmd>Find<cr>')
  vim.keymap.set('n', '<c-f>', '<cmd>Find<cr>')
  vim.keymap.set('n', '<leader>/', [[<cmd>lua require('vscode').action('workbench.action.findInFiles')<cr>]])
  vim.keymap.set('n', '<leader>ss', [[<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<cr>]])

  -- Keep undo/redo lists in sync with VsCode
  vim.keymap.set('n', 'u', "<Cmd>call VSCodeNotify('undo')<CR>")
  vim.keymap.set('n', '<C-r>', "<Cmd>call VSCodeNotify('redo')<CR>")
end

local function tab()
  if vim.g.suggestions == 'copilot' and vim.lsp.inline_completion.get() then
    return
  end

  if vim.g.suggestions == 'gitlab' then
    local GhostText = require('gitlab.ghost_text')
    local ns = vim.api.nvim_create_namespace('gitlab.GhostText')
    local bufnr = vim.api.nvim_get_current_buf()
    local has_suggestion = #vim.api.nvim_buf_get_extmarks(bufnr or 0, ns, 0, -1, { limit = 1 }) > 0
    if has_suggestion then
      GhostText.insert_ghost_text()
      return
    end
  end

  if require('copilot-nes').apply() then
    return
  end

  if require('blink.cmp').accept() then
    return
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
end

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    spec = {
      { '<leader>y', group = 'yank' },
    },
  },
  keys = {

    { mode = 't', '<esc>', [[<C-\><C-n>]] },
    { mode = 't', '<c-esc>', '<esc>' },
    { mode = 't', '<c-bs>', '<esc>' },

    {
      mode = { 'i', 'n', 's' },
      '<esc>',
      function()
        vim.cmd('noh')
        require('copilot-nes').clear()
        return '<esc>'
      end,
      expr = true,
      desc = 'Escape and Clear hlsearch',
    },

    -- save file
    { mode = { 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', desc = 'Save File' },

    --------------------
    -- Which Key
    --------------------
    { '<localleader>', '<cmd>lua require("which-key").show("' .. vim.g.maplocalleader .. '")<cr>' },

    --------------------
    -- Text Manipulation
    --------------------

    {
      mode = { 'n', 'v' },
      'c',
      '<cmd>lua vim.g.change = true<cr>c',
      noremap = true,
      desc = 'Change',
    },
    { mode = 'c', '<esc>', '<C-c>', desc = 'Exit insert mode' },
    { mode = 'v', '/', '"hy/<C-r>h', desc = 'Search word' },
    {
      mode = 'v',
      '<leader>rr',
      function()
        local text = require('util.util').get_visual_selection_text()
        return '<esc>:%s/' .. text .. '//g<left><left>'
      end,
      desc = 'Replace Visual Selection',
      expr = true,
    },

    { '<leader>rr', function() vim.fn.feedkeys(':%s/', 't') end, desc = 'Replace' },
    {
      '<leader>rw',
      function() return ':%s/' .. vim.fn.expand('<cword>') .. '//g<left><left>' end,
      desc = 'Replace word under cursor',
      expr = true,
    },
    { '<leader>A', '<cmd>silent %y+<cr>', desc = 'Copy all' },
    { mode = { 'n', 'v' }, '>>', '>>', remap = false, desc = 'Increase Indent' },
    { mode = { 'n', 'v' }, '<<', '<<', remap = false, desc = 'Decrease Indent' },
    { mode = 'x', '<', '<gv' },
    { mode = 'x', '>', '>gv' },

    { mode = { 'i', 'n' }, '<Tab>', tab, desc = 'Next suggestion' },
    {
      mode = { 'i', 'n' },
      '<S-Tab>',
      function()
        if not require('copilot-nes').apply() then
          return '<S-Tab>'
        end
      end,
      desc = 'Next suggestion',
      expr = true,
    },

    ------------------
    -- Paste
    ------------------
    -- Paste over motion/textobject: enter operator-pending mode with `p`
    {
      '<leader>v',
      function()
        vim.go.operatorfunc = 'v:lua.custom_operator_paste'
        vim.api.nvim_feedkeys('g@', 'n', false)
      end,
      desc = 'Paste over motion/textobject',
      repeatable = true,
    },
    {
      '<leader>yP',
      function()
        local path = vim.fn.expand('%:p')
        vim.fn.setreg('+', path)
        vim.notify(path, vim.log.levels.INFO, { title = 'copied' })
      end,
      desc = 'Copy absolute file path',
    },
    {
      '<leader>yp',
      function()
        local path = vim.fn.expand('%')
        vim.fn.setreg('+', path)
        vim.notify(path, vim.log.levels.INFO, { title = 'copied' })
      end,
      desc = 'Copy relative file path',
    },

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

    -- new file
    { '<leader>fn', '<cmd>enew<cr>', desc = 'New File' },

    ------------------
    -- Tab Management
    ------------------
    { '<S-up>', '<cmd>tabnext<cr>', desc = 'Tab Next' },
    { '<S-down>', '<cmd>tabprev<cr>', desc = 'Tab Prev' },
    { '<C-t>', '<cmd>tabnew<cr>', desc = 'Tab New' },
    { 'gq', '<cmd>tabclose<cr>', desc = 'Tab Close' },
    { '<leader><tab>h', function() require('util.tabpages').move_buffer_to_tab('prev', true) end, desc = 'Tab Move Prev' },
    { '<leader><tab>l', function() require('util.tabpages').move_buffer_to_tab('next', true) end, desc = 'Tab Move Next' },
    { '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' } },
    { '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'Tab First' } },
    { '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'Tab New' } },
    { '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Tab Close' } },
    { '<leader><tab>q', '<cmd>tabclose<cr>', { desc = 'Tab Close' } },

    ------------------
    -- Jupytext
    ------------------
    { '<leader>njs', function() require('util.jupytext').sync() end, desc = 'Jupytext Sync' },
    { '<leader>njp', function() require('util.jupytext').pair() end, desc = 'Jupytext Pair' },
    { '<leader>njc', function() require('util.jupytext').to_notebook() end, desc = 'Jupytext Convert' },
    { '<leader>njl', function() require('util.jupytext').to_paired_notebook() end, desc = 'Jupytext Link' },

    ------------------
    -- Terminal
    ------------------
    {
      '<F8>',
      function() require('util.term.core').toggle_floating() end,
      desc = 'Toggle floating/standard terminal',
    },
  },
}
