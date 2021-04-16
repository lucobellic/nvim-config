local saga = require'lspsaga'
local cmd = vim.cmd

saga.init_lsp_saga {
  use_saga_diagnostic_sign = false,
  error_sign = '-',
  warn_sign = '-',
  hint_sign = '-',
  infor_sign = '-'
}

cmd('nnoremap <silent> g; <cmd>lua require(\'lspsaga.floaterm\').open_float_terminal(\'lazygit\')<CR>')
cmd('tnoremap <silent> g; <C-\\><C-n>:lua require(\'lspsaga.floaterm\').close_float_terminal()<CR>')

