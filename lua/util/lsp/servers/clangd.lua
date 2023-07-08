local Path = require("plenary.path")

local mason_clangd_path = Path:new(vim.fn.stdpath("data")):joinpath("mason", "bin", "clangd"):absolute()

-- TODO: set it in clangd.setup
vim.cmd([[map <silent> <M-o> :ClangdSwitchSourceHeader <CR>]])

return {
  cmd = {
    mason_clangd_path,
    "--background-index",
    "--background-index-priority=background",
    "--all-scopes-completion",
    "--pch-storage=memory",
    "--clang-tidy",
    "--enable-config",
    "--header-insertion=iwyu",
    "--all-scopes-completion",
    "--compile-commands-dir=/home/rosuser/build",
    "-j",
    "2",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  capabilities = {
    offsetEncoding = { "utf-16" },
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
}
