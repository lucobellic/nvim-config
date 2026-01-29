if vim.g.vscode then
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

return {
  {
    'mason-org/mason.nvim',
    cmd = { 'Mason' },
    opts = {
      PATH = 'prepend',
      ui = {
        backdrop = 100,
        border = vim.g.border.style,
        width = 0.8,
        height = 0.8,
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    event = 'LspAttach',
    opts = function(_, opts)
      opts = vim.tbl_deep_extend('force', opts or {}, {
        codelens = { enabled = false },
        inlay_hints = { enabled = false },
        diagnostics = {
          virtual_text = false,
          virtual_lines = false,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = '┊',
              [vim.diagnostic.severity.WARN] = '┊',
              [vim.diagnostic.severity.INFO] = '┊',
              [vim.diagnostic.severity.HINT] = '┊',
            },
            numhl = {
              [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
              [vim.diagnostic.severity.WARN] = 'DiagnosticWarn',
              [vim.diagnostic.severity.INFO] = 'DiagnosticInfo',
              [vim.diagnostic.severity.HINT] = 'DiagnosticHint',
            },
          },
          underline = true,
          update_in_insert = false, -- Disable to remove blinking while in insert mode
          severity_sort = true,
          float = { source = true, header = {}, border = vim.g.border.style },
        },
      })

      -- Disable auto-installation of nil_ls
      opts.servers = opts.servers or {}
      opts.servers.nil_ls = vim.tbl_deep_extend('force', opts.servers.nil_ls or {}, {
        mason = false,
        enabled = false,
      })
      require('lspconfig.ui.windows').default_options.border = vim.g.border.style

      return opts
    end,
  },
  {
    'neovim/nvim-lspconfig',
    optional = true,
    keys = {
      {
        '[d',
        function() require('lspsaga.diagnostic'):goto_prev({ severity = { min = vim.diagnostic.severity.HINT } }) end,
        repeatable = true,
        desc = 'Previous Diagnostic',
      },
      {
        ']d',
        function() require('lspsaga.diagnostic'):goto_next({ severity = { min = vim.diagnostic.severity.HINT } }) end,
        repeatable = true,
        desc = 'Next Diagnostic',
      },
      {
        '[w',
        function() require('lspsaga.diagnostic'):goto_prev({ severity = { min = vim.diagnostic.severity.WARN } }) end,
        repeatable = true,
        desc = 'Previous Warning',
      },
      {
        ']w',
        function() require('lspsaga.diagnostic'):goto_next({ severity = { min = vim.diagnostic.severity.WARN } }) end,
        repeatable = true,
        desc = 'Next Warning',
      },
      {
        '[e',
        function() require('lspsaga.diagnostic'):goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
        repeatable = true,
        desc = 'Previous Error',
      },
      {
        ']e',
        function() require('lspsaga.diagnostic'):goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
        repeatable = true,
        desc = 'Next Error',
      },
    },
    opts = {
      servers = {
        ['*'] = {
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = true,
                lineFoldingOnly = true,
              },
            },
          },
          keys = {
            { '<leader>cc', false, mode = { 'n', 'v' } },
            { '<leader>cC', false, mode = { 'n', 'v' } },
            { '<c-k>', false, mode = { 'n', 'v', 'i' } },
            { 'gs', false, mode = { 'n', 'v' } },
            { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition', has = 'definition' },
            { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
            { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
            { 'gi', function() Snacks.picker.lsp_incoming_calls() end, desc = 'Goto Incoming Calls' },
            { 'go', function() Snacks.picker.lsp_outgoing_calls() end, desc = 'Goto Outgoing Calls' },
            {
              '<leader>ss',
              function() Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter }) end,
              desc = 'LSP Symbols',
              has = 'documentSymbol',
            },
            {
              '<leader>sS',
              function() Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter }) end,
              desc = 'LSP Workspace Symbols',
              has = 'workspace/symbols',
            },
            {
              '<leader>SS',
              function() Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter }) end,
              desc = 'LSP Workspace Symbols',
              has = 'workspace/symbols',
            },
            { 'gS', function() vim.lsp.buf.signature_help() end, desc = 'Signature Help', has = 'signatureHelp' },
            {
              'K',
              function()
                local under_cursor = ' ' .. vim.fn.expand('<cword>') .. ' '
                vim.lsp.buf.hover({ border = vim.g.border.style, title = under_cursor, title_pos = 'center' })
              end,
              mode = { 'n', 'v' },
              desc = 'Hover',
            },
            { '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>' },
            { '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>' },
            { '<leader>rf', '<cmd>lua vim.lsp.buf.code_action({"refactor"})<CR>' },
            {
              '<leader>=',
              function() require('lazyvim.util.format').format({ force = true }) end,
              desc = 'Format Document',
              has = 'documentFormatting',
            },
            {
              '<leader>=',
              function() require('lazyvim.util.format').format({ force = true }) end,
              desc = 'Format Range',
              mode = 'v',
              has = 'documentRangeFormatting',
            },
            {
              '<F2>',
              function() vim.lsp.buf.rename() end,
              desc = 'Rename current symbol',
              cond = 'textDocument/rename',
            },
            { 'gK', '<cmd>Lspsaga hover_doc<CR>' },
          },
        },
      },
    },
  },
}
