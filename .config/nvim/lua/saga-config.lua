local saga = require('lspsaga')

saga.init_lsp_saga {
  use_saga_diagnostic_sign = true,
  border_style = 'single',
  error_sign = '-',
  warn_sign = '-',
  hint_sign = '-',
  infor_sign = '-'
}
