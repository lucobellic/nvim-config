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
    event = "VeryLazy",
    config = function()
      require("copilot_cmp").setup()
    end
  },

  -- Snippets
  { 'saadparwaiz1/cmp_luasnip',     event = "VeryLazy" },
  { 'rafamadriz/friendly-snippets', event = "VeryLazy" },
  {
    'L3MON4D3/LuaSnip',
    event = "VeryLazy",
    config = function()
      require('luasnip.loaders.from_vscode').lazy_load()
    end
  },

  { 'hrsh7th/cmp-nvim-lsp', event = "VeryLazy" },
  { 'hrsh7th/cmp-buffer',   event = "VeryLazy" },
  { 'hrsh7th/cmp-path',     event = "VeryLazy" },
  { 'hrsh7th/cmp-cmdline',  event = "VeryLazy" },
  {
    'hrsh7th/nvim-cmp',
    event = "VeryLazy",
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
    event = 'VeryLazy',
    opts = {
      api_token = "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",
      model = "bigcode/starcoder",
      query_params = {
        max_new_tokens = 200,
      },
    },
    config = function()
      vim.api.nvim_create_user_command("StarCoder", function()
        require("hfcc.completion").complete()
      end, {})
    end,
  },
}

return completion_plugins
