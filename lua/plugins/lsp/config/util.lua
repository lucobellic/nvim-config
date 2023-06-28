local M = {}

function M.on_attach(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  -- local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings
  local opts = { noremap = true, silent = true }

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>TroubleToggle lsp_definitions<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gK', '<cmd>Lspsaga hover_doc<CR>', opts)
  -- buf_set_keymap('n', '<leader>d' , '<Cmd>lua vim.lsp.buf.hover()<CR>'                                     , opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  buf_set_keymap('n', 'gr', '<cmd>TroubleToggle lsp_references<CR>', opts)

  -- buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

  -- TODO: Setup proper refactoring shortcut
  buf_set_keymap('n', '<leader>rf', '<cmd>lua vim.lsp.buf.code_action({"refactor"})<CR>', opts)


  buf_set_keymap('n', '<leader>cf', '<cmd>lua require("plugins.lsp.fixcurrent")()<CR>', opts)
  -- buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.show_line_diagnostics()<CR>', opts)
  -- buf_set_keymap('n', '<C'        , '<cmd>lua vim.diagnostic.goto_prev()<CR>'                              , opts)
  -- buf_set_keymap('n', '>C'        , '<cmd>lua vim.diagnostic.goto_next()<CR>'                              , opts)

  buf_set_keymap('n', '<F2>', '<cmd>Lspsaga rename<CR>', opts)

  -- Code action
  buf_set_keymap('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>', opts)
  buf_set_keymap('v', '<leader>ca', '<cmd><C-U>Lspsaga range_code_action<CR>', opts)

  -- Diagnsotic jump
  buf_set_keymap("n", "<C", "<cmd>silent Lspsaga diagnostic_jump_prev<CR>",
    vim.tbl_deep_extend('keep', opts, { desc = 'Previous Diagnostic' }))
  buf_set_keymap("n", ">C", "<cmd>silent Lspsaga diagnostic_jump_next<CR>",
    vim.tbl_deep_extend('keep', opts, { desc = 'Next Diagnostic' }))

  local key_opts = { noremap = true, silent = true, buffer = bufnr }

  -- Jump to warning or above
  vim.keymap.set(
    "n", "<W",
    function()
      require('lspsaga.diagnostic'):goto_prev({ severity = { min = vim.diagnostic.severity.WARN } })
    end,
    vim.tbl_deep_extend('keep', key_opts, { desc = 'Previous Warning' })
  )

  vim.keymap.set(
    "n", ">W",
    function()
      require('lspsaga.diagnostic'):goto_next({ severity = { min = vim.diagnostic.severity.WARN } })
    end,
    vim.tbl_deep_extend('keep', key_opts, { desc = 'Next Warning' })
  )

  -- Jump to error
  vim.keymap.set(
    "n", "<E",
    function()
      require('lspsaga.diagnostic'):goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end,
    vim.tbl_deep_extend('keep', key_opts, { desc = 'Previous Error' })
  )

  vim.keymap.set(
    "n", ">E",
    function()
      require('lspsaga.diagnostic'):goto_next({ severity = vim.diagnostic.severity.ERROR })
    end,
    vim.tbl_deep_extend('keep', key_opts, { desc = 'Next Error' })
  )

  -- Set some keybinding conditional on server capabilities
  local caps = client.server_capabilities
  if caps.documentFormattingProvider then
    buf_set_keymap("n", "<leader>=", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", opts)
    buf_set_keymap("v", "<leader>=", "<cmd>lua vim.lsp.buf.format({async=true})<CR>", opts)
  end
end

-- Add capabilities supported by nvim-cmp
M.capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Enable folding to work with nvim-ufo
M.capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

return M
