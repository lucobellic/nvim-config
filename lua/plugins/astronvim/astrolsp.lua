return {
  {
    'AstroNvim/astrolsp',
    ---@type AstroLSPOpts
    opts = {
      features = {
        codelens = true,        -- enable/disable codelens refresh on start
        inlay_hints = false,    -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
      formatting = {
        format_on_save = {
          enabled = false,
          allow_filetypes = {},
          ignore_filetypes = {},
        },
        disabled = {},
        timeout_ms = 1000,
        -- filter = function(client) -- fully override the default formatting function
        --   return true
        -- end
      },
      -- enable servers that you already have installed without mason
      servers = {},
      -- customize language server configuration options passed to `lspconfig`
      ---@diagnostic disable: missing-fields
      config = {
        lua_ls = {
          settings = {
            Lua = {
              hint = {
                enable = true,
                setType = true,
                arrayIndex = 'Disable',
              },
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        clangd = {
          keys = {
            { '<M-o>', '<cmd>ClangdSwitchSourceHeader<cr>', desc = 'Switch Source/Header (C/C++)' },
          },
          cmd = {
            'clangd',
            '--background-index',
            '--background-index-priority=background',
            '--all-scopes-completion',
            '--pch-storage=memory',
            '--completion-style=detailed',
            '--clang-tidy',
            '--enable-config',
            '--header-insertion=iwyu',
            '--all-scopes-completion',
            '-j',
            '2',
          },
          filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
          root_dir = function(fname) return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1]) end,
          capabilities = {
            offsetEncoding = { 'utf-16' },
            textDocument = {
              inlayHints = { enabled = true },
              completion = { editsNearCursor = true },
            },
          },
          settings = {
            clangd = {
              semanticHighlighting = true,
            },
          },
        },
      },
      handlers = {
        -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
        -- function(server, opts) require("lspconfig")[server].setup(opts) end

        -- the key is the server that is being setup with `lspconfig`
        -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
        -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
      },
      autocmds = {
        lsp_codelens_refresh = {
          -- Optional condition to create/delete auto command group
          -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
          -- condition will be resolved for each client on each execution and if it ever fails for all clients,
          -- the auto commands will be deleted for that buffer
          cond = 'textDocument/codeLens',
          -- cond = function(client, bufnr) return client.name == "lua_ls" end,
          -- list of auto commands to set
          {
            -- events to trigger
            event = { 'InsertLeave', 'BufEnter' },
            -- the rest of the autocmd options (:h nvim_create_autocmd)
            desc = 'Refresh codelens (buffer)',
            callback = function(args)
              if require('astrolsp').config.features.codelens then
                vim.lsp.codelens.refresh({ bufnr = args.buf })
              end
            end,
          },
        },
      },
      mappings = {
        n = {
          gd = {
            function() Snacks.picker.lsp_definitions() end,
            desc = 'Goto Definition',
          },
          gD = {
            function() Snacks.picker.lsp_declarations() end,
            desc = 'Goto Declaration',
          },
          gr = {
            function() Snacks.picker.lsp_references() end,
            nowait = true,
            desc = 'References',
          },
          gI = {
            function() Snacks.picker.lsp_implementations() end,
            desc = 'Goto Implementation',
          },
          gy = {
            function() Snacks.picker.lsp_type_definitions() end,
            desc = 'Goto T[y]pe Definition',
          },
          ['<F2>'] = {
            function() vim.lsp.buf.rename() end,
            desc = 'Rename current symbol',
            cond = 'textDocument/rename',
          },
          ['<Leader>='] = {
            function() vim.lsp.buf.format({}) end,
            desc = 'Format current buffer',
          },
          ['<Leader>uY'] = {
            function() require('astrolsp.toggles').buffer_semantic_tokens() end,
            desc = 'Toggle LSP semantic highlight (buffer)',
            cond = function(client)
              return client.supports_method('textDocument/semanticTokens/full') and vim.lsp.semantic_tokens ~= nil
            end,
          },
          ['[d'] = {
            function() require('lspsaga.diagnostic'):goto_prev({ severity = { min = vim.diagnostic.severity.HINT } }) end,
            repeatable = true,
            desc = 'Previous Diagnostic',
          },
          [']d'] = {
            function() require('lspsaga.diagnostic'):goto_next({ severity = { min = vim.diagnostic.severity.HINT } }) end,
            repeatable = true,
            desc = 'Next Diagnostic',
          },

          ['[w'] = {
            function() require('lspsaga.diagnostic'):goto_prev({ severity = { min = vim.diagnostic.severity.WARN } }) end,
            repeatable = true,
            desc = 'Previous Warning',
          },
          [']w'] = {
            function() require('lspsaga.diagnostic'):goto_next({ severity = { min = vim.diagnostic.severity.WARN } }) end,
            repeatable = true,
            desc = 'Next Warning',
          },

          ['[e'] = {
            function() require('lspsaga.diagnostic'):goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
            repeatable = true,
            desc = 'Previous Error',
          },
          [']e'] = {
            function() require('lspsaga.diagnostic'):goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
            repeatable = true,
            desc = 'Next Error',
          },
        },
      },
      -- A custom `on_attach` function to be run after the default `on_attach` function
      -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
      on_attach = function(client, bufnr)
        -- this would disable semanticTokensProvider for all clients
        -- client.server_capabilities.semanticTokensProvider = nil
      end,
    },
  },
}
