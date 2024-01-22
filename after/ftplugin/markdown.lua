local buf = vim.api.nvim_get_current_buf()
if require('util.util').is_gp_file(vim.api.nvim_buf_get_name(buf)) then
  vim.opt_local.number = false
  vim.opt_local.spell = false
  vim.diagnostic.disable(buf)
  vim.api.nvim_set_option_value('buftype', 'prompt', { buf = buf })
  vim.fn.prompt_setcallback(buf, function() vim.api.nvim_command('GpChatRespond') end)
  vim.fn.prompt_setprompt(buf, '')
end
