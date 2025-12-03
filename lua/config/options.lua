-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = ' '
vim.g.maplocalleader = '_'
vim.g.autoformat = false
vim.g.markdown_folding = true

vim.g.winborder = vim.g.neovide_floating_shadow and 'solid' or 'single'
vim.o.winborder = vim.g.winborder

local enable_border = true
vim.g.border = {
  enabled = enable_border,
  style = enable_border and vim.g.winborder or { ' ' },
  borderchars = enable_border and { '─', '│', '─', '│', '┌', '┐', '┘', '└' }
    or { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
}

vim.g.ai_cmp = false
vim.g.cmp_mode = 'super-tab' --- @type 'default'|'super-tab'|'enter'|'none'
vim.opt.completeopt = ''
vim.opt.wildmenu = false
vim.opt.wildmode = ''

vim.opt.conceallevel = 2
vim.opt.laststatus = 3
vim.opt.signcolumn = 'yes:2'
vim.opt.cursorline = true

vim.opt.more = false

-- Disable support for keymap part of a sequence
if not vim.g.vscode then
  vim.opt.timeout = true
  vim.opt.timeoutlen = 0
end

vim.opt.foldlevel = 99

vim.opt.sessionoptions = {
  'buffers',
  'curdir',
  'folds',
  'globals',
  'help',
  'skiprtp',
  'tabpages',
  'winpos',
  'winsize',
}

-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = 'screen'
vim.opt.cursorlineopt = 'screenline'

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.wrap = false
vim.opt.showbreak = '↪'
vim.opt.breakindent = true

vim.opt.autoread = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.pumblend = 0
vim.opt.winblend = 0

vim.opt.spell = false
vim.opt_global.incsearch = false

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
  fold = ' ',
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

vim.opt.virtualedit = 'block'

vim.opt.guicursor = {
  'n:block-Cursor/lCursor',
  'v:block-CursorVisual',
  'c:ver15-CursorOperator',
  't-i-ci-ve:ver15-CursorInsert',
  'r-cr-o:hor20-CursorOperator',
  'a:blinkon0',
}

vim.g.lion_squeeze_spaces = true

vim.opt.numberwidth = 1

-- Set python3 host prog to speed up startup
vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.lazyvim_python_lsp = 'basedpyright'

vim.g.kind_filter = vim.g.distribution == 'lazyvim' and LazyVim.config.kind_filter
  or {
    default = {
      'Class',
      'Constructor',
      'Enum',
      'Field',
      'Function',
      'Interface',
      'Method',
      'Module',
      'Namespace',
      'Package',
      'Property',
      'Struct',
      'Trait',
    },
    markdown = false,
    help = false,
    -- you can specify a different filter for each filetype
    lua = {
      'Class',
      'Constructor',
      'Enum',
      'Field',
      'Function',
      'Interface',
      'Method',
      'Module',
      'Namespace',
      -- "Package", -- remove package since luals uses it for control flow structures
      'Property',
      'Struct',
      'Trait',
    },
  }
