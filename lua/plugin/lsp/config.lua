local nvim_lsp = require('lspconfig')


local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings
  local opts = { noremap = true, silent = true }

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  -- buf_set_keymap('n', 'K'         , '<cmd>lua vim.lsp.buf.hover()<CR>'                                     , opts)
  -- buf_set_keymap('n', '<leader>d' , '<Cmd>lua vim.lsp.buf.hover()<CR>'                                     , opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  -- TODO: Setup proper refactoring shortcut
  buf_set_keymap('n', '<leader>rf', '<cmd>lua vim.lsp.buf.code_action({"refactor"})<CR>', opts)
  -- buf_set_keymap('n', '<F2>'      , '<cmd>lua vim.lsp.buf.rename()<CR>'                                    , opts)
  -- buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>'                               , opts)


  buf_set_keymap('n', '<leader>cf', '<cmd>lua require("plugin.lsp.fixcurrent")()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.show_line_diagnostics()<CR>', opts)
  -- buf_set_keymap('n', '<C'        , '<cmd>lua vim.diagnostic.goto_prev()<CR>'                              , opts)
  -- buf_set_keymap('n', '>C'        , '<cmd>lua vim.diagnostic.goto_next()<CR>'                              , opts)
  buf_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)

  buf_set_keymap('n', '<leader>d', '<cmd>Lspsaga peek_definition<CR>', opts)

  buf_set_keymap('n', '<F2>', '<cmd>Lspsaga rename<CR>', opts)

  -- Code action
  buf_set_keymap('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', opts)
  buf_set_keymap('v', '<leader>ca', '<cmd><C-U>Lspsaga range_code_action<CR>', opts)

  -- Diagnsotic jump
  buf_set_keymap("n", "<C", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
  buf_set_keymap("n", ">C", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)

  -- Only jump to error
  buf_set_keymap("n", "<E", "<cmd> require(lspsaga.diagnostic).goto_prev({ severity = vim.diagnostic.severity.ERROR })", opts)
  buf_set_keymap("n", ">E", "<cmd> require(lspsaga.diagnostic).goto_next({ severity = vim.diagnostic.severity.ERROR })", opts)

  -- Set some keybinds conditional on server capabilities
  local caps = client.server_capabilities
  if caps.documentFormattingProvider then
    buf_set_keymap("n", "<space>=", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", opts)
    buf_set_keymap("v", "<space>=", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", opts)
  end

  if caps.semanticTokensProvider and caps.semanticTokensProvider.full then
    local augroup = vim.api.nvim_create_augroup("SemanticTokens", {})
    vim.api.nvim_create_autocmd("TextChanged", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.semantic_tokens_full()
      end,
    })
    -- fire it first time on load as well
    vim.lsp.buf.semantic_tokens_full()
  end

end

-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = { 'sumneko_lua', 'rust_analyzer', 'jsonls', 'vimls', 'cmake' }
-- local servers = {'pyright', 'clangd', 'cmake-language-server', 'docker-langserver', 'json', 'vim', 'lua'
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities
  }
end

nvim_lsp.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    pyright = {
      disableLanguageServices = false,
      disableOrganizeImports  = false,
      analysis = {
        autoSearchPaths        = true,
        autoImportCompletions  = true,
        diagnosticMode         = 'workspace',
        typeCheckingMode       = 'basic',
        useLibraryCodeForTypes = true,
      }
    }
  }
}

-- nvim_lsp.pylsp.setup{
--   on_attach = on_attach,
--   capabilities = capabilities,
-- }


-- C/C++ Clangd configuration
-- local nvim_lsp_clangd_highlight = require('nvim-lsp-clangd-highlight')
nvim_lsp.clangd.setup {
  -- on_init = nvim_lsp_clangd_highlight.on_init,
  on_attach = on_attach,
  cmd = { "clangd", "--background-index", "--clang-tidy", "--enable-config" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  settings = {
    semanticHighlighting = true
  },
  capabilities = capabilities
}

-- TODO: set it in clangd.setup
vim.cmd [[map <silent> <M-o> :ClangdSwitchSourceHeader <CR>]]

local signs = { Error = "•", Warn = "•", Hint = "•", Info = "•" }
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { source = true, header = {} }
})

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Highlight line number instead of having icons in sign column
vim.cmd [[
  hi link DiagnosticLineNrError DiagnosticError
  hi link DiagnosticLineNrWarn  DiagnosticWarn
  hi link DiagnosticLineNrInfo  DiagnosticInfo
  hi link DiagnosticLineNrHint  DiagnosticInfo

  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]]
