vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'cpp' },
  command = 'setlocal commentstring=//\\ %s',
  desc = 'Set // as defalut comment string for c++',
})

-- Display cursorline only in focused window
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'WinEnter' }, {
  pattern = '*',
  command = 'setlocal cursorline',
  desc = 'Display cursorline only in focused window',
})
vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  pattern = '*',
  command = 'setlocal nocursorline',
  desc = 'Hide cursorline when leaving window',
})

-- Automatic save
vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
  pattern = '*',
  callback = function(ev)
    local modified = vim.bo.modifiable and vim.bo.modified
    local not_popup = vim.fn.pumvisible() == 0 -- or vim.api.nvim_win_get_config(0).zindex
    if modified and not_popup then
      -- Save and restore cursor position
      local cursor = vim.api.nvim_win_get_cursor(0)
      -- Remove trailing whitespace
      vim.cmd('silent! %s/\\s\\+$//e')
      vim.cmd('silent! write')
      vim.api.nvim_win_set_cursor(0, cursor)
    end
  end,
  desc = 'Automatic save after insertion leave',
})

-- Diagnostic toggle
vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualText',
  function()
    vim.diagnostic.config({
      virtual_text = not vim.diagnostic.config().virtual_text
    })
  end,
  { desc = 'Toggle diagnostic virtual text' }
)

vim.api.nvim_create_user_command(
  'ToggleDiagnosticVirtualLines',
  function()
    vim.diagnostic.config({
      virtual_lines = not vim.diagnostic.config().virtual_lines
    })
  end,
  { desc = 'Toggle diagnostic virtual lines' }
)


