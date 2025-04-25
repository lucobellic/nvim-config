local M = {}

function M.setup_vscode()
  local vscode = require('vscode')
  vim.keymap.set(
    'n',
    'gr',
    function() vscode.action('references-view.findReferences') end,
    { desc = 'Find All References' }
  )
  vim.keymap.set('n', '>D', function() vscode.action('editor.action.marker.next') end, { desc = 'Next Diagnostic' })
  vim.keymap.set('n', '>E', function() vscode.action('editor.action.marker.next') end, { desc = 'Next Diagnostic' })
  vim.keymap.set('n', '>W', function() vscode.action('editor.action.marker.next') end, { desc = 'Next Diagnostic' })
  vim.keymap.set('n', '<D', function() vscode.action('editor.action.marker.prev') end, { desc = 'Prev Diagnostic' })
  vim.keymap.set('n', '<E', function() vscode.action('editor.action.marker.prev') end, { desc = 'Prev Diagnostic' })
  vim.keymap.set('n', '<W', function() vscode.action('editor.action.marker.prev') end, { desc = 'Prev Diagnostic' })
end

function M.setup()
  local format = function()
    require('lazyvim.util.format').format({ force = true })
    -- vim.lsp.buf.format()
  end
  local keys = require('lazyvim.plugins.lsp.keymaps').get()

  -- Remove codelens keymap
  keys[#keys + 1] = { '<leader>cc', false, mode = { 'n', 'v' } }
  keys[#keys + 1] = { '<leader>cC', false, mode = { 'n', 'v' } }
  keys[#keys + 1] = { '<c-k>', false, mode = { 'n', 'v', 'i' } }

  keys[#keys + 1] = { 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>' }

  keys[#keys + 1] = { '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>' }
  keys[#keys + 1] = { '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>' }

  keys[#keys + 1] = { '<leader>rf', '<cmd>lua vim.lsp.buf.code_action({"refactor"})<CR>' }

  -- Format
  keys[#keys + 1] = { '<leader>=', format, desc = 'Format Document', has = 'documentFormatting' }
  keys[#keys + 1] = { '<leader>=', format, desc = 'Format Range', mode = 'v', has = 'documentRangeFormatting' }

  -- Lspsaga
  keys[#keys + 1] = { '<F2>', '<cmd>Lspsaga rename<CR>' }
  keys[#keys + 1] = { 'gK', '<cmd>Lspsaga hover_doc<CR>' }

  -- Jump to previous or next diagnostic
  keys[#keys + 1] = {
    '[d',
    function() require('lspsaga.diagnostic'):goto_prev({ severity = { min = vim.diagnostic.severity.HINT } }) end,
    repeatable = true,
    desc = 'Previous Diagnostic',
  }

  keys[#keys + 1] = {
    ']d',
    function() require('lspsaga.diagnostic'):goto_next({ severity = { min = vim.diagnostic.severity.HINT } }) end,
    repeatable = true,
    desc = 'Next Diagnostic',
  }

  -- Jump to warning or above
  keys[#keys + 1] = {
    '[w',
    function() require('lspsaga.diagnostic'):goto_prev({ severity = { min = vim.diagnostic.severity.WARN } }) end,
    repeatable = true,
    desc = 'Previous Warning',
  }

  keys[#keys + 1] = {
    ']w',
    function() require('lspsaga.diagnostic'):goto_next({ severity = { min = vim.diagnostic.severity.WARN } }) end,
    repeatable = true,
    desc = 'Next Warning',
  }

  -- Jump to error
  keys[#keys + 1] = {
    '[e',
    function() require('lspsaga.diagnostic'):goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
    repeatable = true,
    desc = 'Previous Error',
  }

  keys[#keys + 1] = {
    ']e',
    function() require('lspsaga.diagnostic'):goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
    repeatable = true,
    desc = 'Next Error',
  }
end

return M
