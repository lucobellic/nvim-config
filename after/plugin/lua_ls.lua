vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      format = {
        enable = false,
      },
      workspace = {
        checkThirdParty = false,
      },
      codeLens = {
        enable = true,
      },
      completion = {
        callSnippet = 'Replace',
      },
      doc = {
        privateName = { '^_' },
      },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        semicolon = 'Disable',
        arrayIndex = 'Disable',
      },
    },
  },
})
