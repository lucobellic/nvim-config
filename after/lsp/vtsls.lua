return {
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
    },
    typescript = {},
  },
  before_init = function(_, config)
    local pnp = vim.fs.find({ '.pnp.cjs' }, { upward = true })[1]
    if pnp then
      config.settings.typescript.tsdk = vim.fs.dirname(pnp) .. '/.yarn/sdks/typescript/lib'
    end
  end,
}

