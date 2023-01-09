local editor_plugins = {
    { 'folke/zen-mode.nvim', config = function() require('plugin.editor.zenmode') end },
    { 'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'limelight.vim') end }, -- Highlight paragraph
    { 'luochen1990/rainbow', config = function() vim.cmd('source ' .. config_path .. '/' .. 'rainbow.vim') end },

    -- smooth scroll
    { 'karb94/neoscroll.nvim', config = function() require('plugin.editor.neoscroll') end },

    { 'lukas-reineke/indent-blankline.nvim', config = function() require('plugin.editor.indent') end },
    { 'sindrets/diffview.nvim',
        dependencies = {'nvim-lua/plenary.nvim' } ,
        config = function() require('plugin.editor.diffview') end
    },
}

vim.o.laststatus = 3

vim.o.clipboard = "unnamedplus"
vim.o.number = true
vim.o.signcolumn = "yes:1"
vim.o.cursorline = true

vim.o.autoread = true
vim.o.autowrite = true
vim.o.autowriteall = true

vim.o.timeout = true
vim.o.timeoutlen = 250

vim.o.spell = true

vim.o.wrap = false

vim.o.wmw = 0
vim.o.wmh = 0
vim.o.ignorecase = true

vim.o.hidden = true
vim.o.hidden = true

vim.o.cmdheight = 0
vim.o.updatetime = 400

vim.o.wildmenu = true

vim.o.list = true
vim.o.showbreak = '↪'
vim.opt.listchars = { tab = '- ', trail = '·', extends = '⟩', precedes = '⟨' }

vim.g.lion_squeeze_spaces = true

require('plugin.editor.fold')

return editor_plugins
