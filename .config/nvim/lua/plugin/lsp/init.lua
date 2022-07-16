return {config = function(use)
    use {'neoclide/coc.nvim',
      branch = 'release',
      opt = false,
      -- Keep usage of coc-explorer as file explorer
      -- Keep proper cpp highliglith from coc-highlight and coc-clang as lsp
      run = ':CocInstall coc-explorer coc-highlight coc-clang',
      config = function()
        if vim.g.lsp_provider == 'coc' then
          vim.cmd('source ' .. config_path .. '/' .. 'coc.vim')
        -- else
          -- vim.fn['coc#config']('diagnostic', { enable = false })
        end
        vim.cmd('source ' .. config_path .. '/' .. 'coc-explorer.vim')
      end
    }


    -- Use native nvim lsp
    use {'neovim/nvim-lspconfig',
      requires = {{'williamboman/nvim-lsp-installer'}},
      config = function()
        require('nvim-lsp-installer').setup{}
        require('plugin.lsp.config')
      end
    }
  end
}

