-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.autoformat = false

vim.o.conceallevel = 2
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
vim.o.pumblend = vim.g.neovide and 100 or 0
vim.o.winblend = vim.g.neovide and 100 or 0

vim.go.incsearch = false

vim.opt.listchars = {
  tab = ' ',
  trail = '·',
  extends = '',
  precedes = '',
}

vim.opt.diffopt = {
  'internal',
  'filler',
  'closeoff',
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
}

vim.o.virtualedit = 'block'

if vim.g.started_by_firenvim then
  vim.o.guicursor = 'n-v-c:blinkon0'
else
  local blinking = vim.g.neovide and 'blinkon0' or 'blinkwait300-blinkon200-blinkoff150'
  vim.o.guicursor = 'n-v-c:block,i-ci-ve:ver15,r-cr-o:block,a:' .. blinking .. '-Cursor/lCursor'
end

vim.g.lion_squeeze_spaces = true

vim.opt.numberwidth = 1
if vim.fn.has('nvim-0.9.0') == 1 then
  vim.opt.statuscolumn = [[%!v:lua.require'util.statuscolumn'.get()]]
end

-- Set python3 host prog to speed up startup
vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.lazyvim_python_lsp = 'basedpyright'
