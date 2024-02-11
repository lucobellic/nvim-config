local buf = vim.api.nvim_get_current_buf()
local win = vim.api.nvim_get_current_win()
if require('util.util').is_gp_file(vim.api.nvim_buf_get_name(buf)) then
  vim.api.nvim_set_option_value('spell', false, { scope = 'local', win = win })
  vim.api.nvim_set_option_value('number', false, { scope = 'local', win = win })
  vim.diagnostic.disable(buf)
end
