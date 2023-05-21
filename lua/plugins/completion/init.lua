local completion_plugins = {
  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "VeryLazy",
    config = function()
      require("plugins.completion.copilot")
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end
  },

  -- Snippets
  { 'saadparwaiz1/cmp_luasnip' },
  { 'rafamadriz/friendly-snippets' },
  {
    'L3MON4D3/LuaSnip',
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end
  },

  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-cmdline' },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'onsails/lspkind.nvim',
      'zbirenbaum/copilot-cmp'
    },
    config = function()
      require('plugins.completion.comp')
    end
  },

  {
    "huggingface/hfcc.nvim",
    opts = {
      api_token = "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",
      model = "bigcode/starcoder",
      query_params = {
        max_new_tokens = 200,
      },
    },
    init = function()
      vim.api.nvim_create_user_command("StarCoder", function()
        require("hfcc.completion").complete()
      end, {})
    end,
  },
}

return completion_plugins
