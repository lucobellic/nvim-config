local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings
  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gD'        , '<Cmd>lua vim.lsp.buf.declaration()<CR>'                               , opts)
  buf_set_keymap('n', 'gd'        , '<Cmd>lua vim.lsp.buf.definition()<CR>'                                , opts)
  buf_set_keymap('n', 'K'         , '<Cmd>lua vim.lsp.buf.hover()<CR>'                                     , opts)
  buf_set_keymap('n', '<leader>d' , '<Cmd>lua vim.lsp.buf.hover()<CR>'                                     , opts)
  buf_set_keymap('n', 'gi'        , '<cmd>lua vim.lsp.buf.implementation()<CR>'                            , opts)
  buf_set_keymap('n', '<C-k>'     , '<cmd>lua vim.lsp.buf.signature_help()<CR>'                            , opts)
  buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>'                      , opts)
  buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>'                   , opts)
  buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>D' , '<cmd>lua vim.lsp.buf.type_definition()<CR>'                           , opts)
  -- TODO: Setup proper refactoring shortcut
  buf_set_keymap('n', '<space>rf' , '<cmd>lua vim.lsp.buf.code_action({"refactor"})<CR>'                   , opts)
  buf_set_keymap('n', '<F2>'      , '<cmd>lua vim.lsp.buf.rename()<CR>'                                    , opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>'                               , opts)
  buf_set_keymap('n', '<leader>cf', '<cmd>lua require("plugin.lsp.fixcurrent")()<CR>'                      , opts)
  buf_set_keymap('n', 'gr'        , '<cmd>lua vim.lsp.buf.references()<CR>'                                , opts)
  buf_set_keymap('n', '<leader>e' , '<cmd>lua vim.diagnostic.show_line_diagnostics()<CR>'                  , opts)
  buf_set_keymap('n', '<C'        , '<cmd>lua vim.diagnostic.goto_prev()<CR>'                              , opts)
  buf_set_keymap('n', '>C'        , '<cmd>lua vim.diagnostic.goto_next()<CR>'                              , opts)
  buf_set_keymap('n', '<leader>q' , '<cmd>lua vim.diagnostic.set_loclist()<CR>'                            , opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end
end

-- Add additional capabilities supported by nvim-cmp
-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = { 'pyright', 'clangd', 'sumneko_lua', 'rust_analyzer', 'vimls', 'cmake' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach
    -- capabilities = capabilities
  }
end

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
  -- capabilities = capabilities
  capabilities = {
    textDocument = {
      semanticHighlightingCapabilities = {
        semanticHighlighting = true
      }
    }
  },
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
  float = {source = true, header = {}}
})

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Highlight line number instead of having icons in sign column
vim.cmd [[
  hi link DiagnosticLineNrError ErrorMsg
  hi link DiagnosticLineNrWarn WarningMsg
  hi link DiagnosticLineNrInfo DiffChange
  hi link DiagnosticLineNrHint DiffAdd

  sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
  sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
  sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
  sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
]]


