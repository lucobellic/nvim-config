return {
  name = 'run script',
  builder = function()
    local file = vim.fn.expand('%:p')
    local cmd = { file }
    if vim.bo.filetype == 'go' then
      cmd = { 'go', 'run', file }
    elseif vim.bo.filetype == 'lua' then
      cmd = { 'lua', file }
    end
    return { cmd = cmd }
  end,
  condition = {
    filetype = { 'lua', 'sh', 'python', 'go' },
  },
}
