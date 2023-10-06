-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.laststatus = 3

-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.o.splitkeep = 'screen'

vim.o.number = true
vim.o.relativenumber = false

vim.o.showbreak = '↪'

vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
vim.o.pumblend = 20
vim.o.winblend = 20

vim.go.incsearch = false

vim.opt.listchars = {
  tab = ' ',
  trail = '·',
  extends = '',
  precedes = ''
}

vim.opt.fillchars = {
  diff = '╱',
  eob = ' ',
  stl = ' ',
  stlnc = ' ',
  wbr = ' ',
  horiz = '─',
  horizup = '┴',
  horizdown = '┬',
  vert = '│',
  vertleft = '┤',
  vertright = '├',
  verthoriz = '┼',
  fold = '',
  foldsep = ' ',
  foldopen = '',
  foldclose = '',
}

-- Fold configuration
vim.o.foldcolumn = '0'
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

vim.o.guicursor = "n-v-c:block,i-ci-ve:ver15,r-cr-o:block,a:blinkon0-Cursor/lCursor"

vim.g.lion_squeeze_spaces = true
