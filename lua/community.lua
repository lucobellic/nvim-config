-- Import this file before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  'AstroNvim/astrocommunity',
  { import = 'astrocommunity.pack.lua' },
  { import = 'astrocommunity.pack.rust' },
  { import = 'astrocommunity.pack.python' },
  { import = 'astrocommunity.utility.lua-json5' },
  { import = 'astrocommunity.utility.noice-nvim' },
  { import = 'astrocommunity.completion.copilot-vim' },
  { import = 'astrocommunity.debugging.nvim-dap-repl-highlights' },
}
