require("nvim-semantic-tokens").setup {
  preset = "default",
  -- highlighters is a list of modules following the interface of nvim-semantic-tokens.table-highlighter or
  -- function with the signature: highlight_token(ctx, token, highlight) where
  --        ctx (as defined in :h lsp-handler)
  --        token  (as defined in :h vim.lsp.semantic_tokens.on_full())
  --        highlight (a helper function that you can call (also multiple times) with the determined highlight group(s) as the only parameter)
  highlighters = { require 'nvim-semantic-tokens.table-highlighter' }
}

vim.api.nvim_set_hl(0, 'LspNamespace'    , { link = 'TSNamespace' })
vim.api.nvim_set_hl(0, 'LspType'         , { link = 'TSType' })
vim.api.nvim_set_hl(0, 'LspClass'        , { link = 'TSType' })
vim.api.nvim_set_hl(0, 'LspEnum'         , { link = 'TSType' })
vim.api.nvim_set_hl(0, 'LspInterface'    , { link = 'TSType' })
vim.api.nvim_set_hl(0, 'LspStruct'       , { link = 'TSType' })
vim.api.nvim_set_hl(0, 'LspTypeParameter', { link = 'TSParameter' })
vim.api.nvim_set_hl(0, 'LspParameter'    , { link = 'TSParameter' })
vim.api.nvim_set_hl(0, 'LspVariable'     , { link = 'TSVariableBuiltin' })
vim.api.nvim_set_hl(0, 'LspProperty'     , { link = 'TSProperty' })
vim.api.nvim_set_hl(0, 'LspEnumMember'   , { link = 'TSProperty' })
vim.api.nvim_set_hl(0, 'LspEvent'        , { link = 'TSFunction' })
vim.api.nvim_set_hl(0, 'LspFunction'     , { link = 'TSFunction' })
vim.api.nvim_set_hl(0, 'LspMethod'       , { link = 'TSMethod' })
vim.api.nvim_set_hl(0, 'LspMacro'        , { link = 'TSFuncMacro' })
vim.api.nvim_set_hl(0, 'LspKeyword'      , { link = 'TSKeyword' })
vim.api.nvim_set_hl(0, 'LspModifier'     , { link = 'TSOperator' })
vim.api.nvim_set_hl(0, 'LspComment'      , { link = 'TSComment' })
vim.api.nvim_set_hl(0, 'LspString'       , { link = 'TSString' })
vim.api.nvim_set_hl(0, 'LspNumber'       , { link = 'TSNumber' })
vim.api.nvim_set_hl(0, 'LspRegexp'       , { link = 'TSStringRegex' })
vim.api.nvim_set_hl(0, 'LspOperator'     , { link = 'TSOperator' })
vim.api.nvim_set_hl(0, 'LspDecorator'    , { link = 'TSKeyword' })

-- semantic_tokens.modifiers_map = {
--   declaration = "LspDeclaration",
--   definition = "LspDefinition",
--   readonly = "LspReadonly",
--   static = "LspStatic",
--   deprecated = "LspDeprecated",
--   abstract = "LspAbstract",
--   async = "LspAsync",
--   modification = "LspModification",
--   documentation = "LspDocumentation",
--   defaultLibrary = "LspDefaultLibrary",
-- }
