vim.o.laststatus = 3

vim.o.clipboard = "unnamedplus"
vim.o.number = true
vim.o.signcolumn = "yes:1"
vim.o.number = true
vim.o.cursorline = true

vim.o.autoread = true
vim.o.autowrite = true
vim.o.autowriteall = true

vim.o.timeout = true
vim.o.timeoutlen = 250

vim.o.spell = false

vim.o.wrap = false

vim.o.wmw = 0
vim.o.wmh = 0
vim.o.ignorecase = true

vim.o.hidden = true
vim.o.hidden = true

vim.o.cmdheight = 0
vim.o.updatetime = 400

vim.o.pumheight = 15
vim.o.wildmenu = true

vim.o.list = true
vim.o.showbreak = '↪'
vim.opt.listchars = { tab = '>-', trail = '·', extends = '⟩', precedes = '⟨' }
vim.opt.fillchars =  {
    diff = '/',
    eob = ' ',
    horiz = ' ',
    horizup = ' ',
    horizdown = ' ',
    vert = ' ',
    vertleft = ' ',
    vertright = ' ',
    verthoriz = ' ',
    fold = ' ',
    foldsep = ' ',
    foldopen = '▾',
    foldclose = '▸',
}

vim.o.guicursor = "n-v-c:hor15,i-ci-ve:ver15,r-cr-o:block,a:blinkon0-Cursor/lCursor"

vim.g.lion_squeeze_spaces = true

-- Display cursorline only in focused window
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
  pattern = "*",
  command = "setlocal cursorline",
})
vim.api.nvim_create_autocmd({ "WinLeave" }, {
  pattern = "*",
  command = "setlocal nocursorline",
})
