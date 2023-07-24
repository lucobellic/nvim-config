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
    "--completion-style=detailed",
    "--clang-tidy",
    "--enable-config",
    "--header-insertion=iwyu",
    "--all-scopes-completion",
    "-j",
    "2",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_dir = function(fname)
    return require("lspconfig.util").find_git_ancestor(fname)
  end,
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
  on_new_config = function(new_config, new_cwd)
    local status, cmake = pcall(require, "cmake-tools")
    if status then
      cmake.clangd_on_new_config(new_config)
    end
  end,
}

