return {config = function(use)

  use {'folke/zen-mode.nvim', config = function() require('plugin.editor.zenmode') end}
  use {'junegunn/limelight.vim', config = function() vim.cmd('source ' .. config_path .. '/' .. 'limelight.vim') end} -- Highlight paragraph

  use {'luochen1990/rainbow', config = function() vim.cmd('source ' .. config_path .. '/' .. 'rainbow.vim') end}
  use  'psliwka/vim-smoothie' -- smooth scroll
  use {'lukas-reineke/indent-blankline.nvim', config = function() require('plugin.editor.indent') end}

  require('plugin.editor.fold')
  vim.opt.laststatus=3

  end
}
