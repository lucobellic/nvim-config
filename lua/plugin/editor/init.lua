return {config = function(use)
    use { 'folke/zen-mode.nvim', config = function() require('plugin.editor.zenmode') end }
    use { 'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'limelight.vim') end } -- Highlight paragraph

    use { 'luochen1990/rainbow', config = function() vim.cmd('source ' .. config_path .. '/' .. 'rainbow.vim') end }
    use { 'psliwka/vim-smoothie', opt = true, cond = function() return vim.g.neovide end } -- smooth scroll
    use { 'lukas-reineke/indent-blankline.nvim', config = function() require('plugin.editor.indent') end }
    use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim', config = function() require('plugin.editor.diffview') end }
    use { 'rcarriga/nvim-notify', config = function() require('plugin.editor.notify') end }

    require('plugin.editor.fold')

    vim.o.laststatus = 3

    vim.o.clipboard = "unnamedplus"
    vim.o.number = true
    vim.o.signcolumn = "yes:1"
    vim.o.cursorline = true

    vim.o.autoread = true
    vim.o.autowrite = true
    vim.o.autowriteall = true

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
    vim.o.showbreak='↪'
    vim.opt.listchars = { tab = '- ', trail = '·', extends = '⟩', precedes='⟨' }

    vim.g.lion_squeeze_spaces = true

  end
}
