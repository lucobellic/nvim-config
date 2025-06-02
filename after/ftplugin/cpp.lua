vim.keymap.set(
  'n',
  '<M-o>',
  '<cmd>LspClangdSwitchSourceHeader<cr>',
  { desc = 'Switch Source/Header (C/C++)', buffer = 0 }
)
