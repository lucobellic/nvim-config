return {
  keys = {
    { "<M-o>", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
  },
  cmd = {
    "clangd",
    "--background-index",
    "--background-index-priority=background",
    "--all-scopes-completion",
    "--pch-storage=memory",
    "--clang-tidy",
    "--enable-config",
    "--header-insertion=iwyu",
    "--all-scopes-completion",
    "--compile-commands-dir=../build",
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
