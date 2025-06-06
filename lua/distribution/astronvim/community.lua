-- Import this file before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  'AstroNvim/astrocommunity',

  { import = 'astrocommunity.color.mini-hipatterns' },
  { import = 'astrocommunity.color.modes-nvim' },
  { import = 'astrocommunity.colorscheme.vscode-nvim' },
  { import = 'astrocommunity.completion.copilot-vim' },
  { import = 'astrocommunity.debugging.nvim-dap-repl-highlights' },
  { import = 'astrocommunity.editing-support.dial-nvim' },
  { import = 'astrocommunity.git.octo-nvim' },
  { import = 'astrocommunity.indent.indent-blankline-nvim' },
  { import = 'astrocommunity.markdown-and-latex.markdown-preview-nvim' },
  { import = 'astrocommunity.motion.mini-ai' },
  { import = 'astrocommunity.motion.mini-surround' },
  { import = 'astrocommunity.pack.ansible' },
  { import = 'astrocommunity.pack.cmake' },
  { import = 'astrocommunity.pack.cpp' },
  { import = 'astrocommunity.pack.docker' },
  { import = 'astrocommunity.pack.json' },
  { import = 'astrocommunity.pack.lua' },
  { import = 'astrocommunity.pack.markdown' },
  { import = 'astrocommunity.pack.nix' },
  { import = 'astrocommunity.pack.python' },
  { import = 'astrocommunity.pack.rust' },
  { import = 'astrocommunity.pack.toml' },
  { import = 'astrocommunity.pack.typescript' },
  { import = 'astrocommunity.pack.yaml' },
  { import = 'astrocommunity.recipes.cache-colorscheme' },
  { import = 'astrocommunity.recipes.vscode' },
  { import = 'astrocommunity.register.nvim-neoclip-lua' },
  { import = 'astrocommunity.snippet.mini-snippets' },
  { import = 'astrocommunity.test.neotest' },
  { import = 'astrocommunity.utility.lua-json5' },
  { import = 'astrocommunity.utility.noice-nvim' },
}
