local title = 'MyTask'
for i = 0, 100, 10 do
  vim.api.nvim_echo(
    { { string.format('%s: %d%%', title, i) } }, -- chunks
    false, -- history?
    { kind = 'progress', percent = i, status = 'running', title = title } -- opts
  )
  vim.wait(150) -- small delay so UI can update (ms)
end
-- finish
vim.api.nvim_echo(
  { { title .. ' complete' } },
  false,
  { kind = 'progress', percent = 100, status = 'success', title = title }
)
