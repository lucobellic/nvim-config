return { config = function(use)
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


    use {'williamboman/mason.nvim', config = function() require('mason').setup() end }
    use {'williamboman/mason-lspconfig.nvim', config = function() require('mason-lspconfig').setup() end }

    -- Use native nvim lsp
    use {'neovim/nvim-lspconfig', config = function() require('plugin.lsp.config') end}

    -- use {'glepnir/lspsaga.nvim', config = function() require('plugin.lsp.lspsaga') end}

    -- Outline
    -- TODO: Change to lsp-saga
    use { 'simrat39/symbols-outline.nvim', config = function () require('plugin.lsp.outline') end }
  end
}

