vim.o.foldcolumn = '0'
vim.o.foldenable = false
vim.o.foldmethod = 'syntax'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

function _G.custom_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  return line .. ' ... ' .. line_count
end

vim.o.foldtext = 'v:lua.custom_fold_text()'

require('ufo').setup()
