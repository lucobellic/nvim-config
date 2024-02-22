return {
  {
    'simrat39/rust-tools.nvim',
    opts = {
      tools = {
        inlay_hints = {
          auto = false,
        },
        reload_workspace_from_cargo_toml = false,
      },
    },
    config = function()
      -- Do not enable rust-tools.nvim
    end,
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^4',
    ft = { 'rust' },
  },
}
