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
      'zbirenbaum/copilot-cmp',
    },
    config = function()
      require('plugins.completion.cmp')
    end
  },

  {
    "huggingface/hfcc.nvim",
    enabled = false,
    event = 'VeryLazy',
    config = function()
      require("hfcc").setup({
        api_token = "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",
        model = "bigcode/starcoder",
        query_params = {
          max_new_tokens = 200,
          max_length = 200,
        },
        accept_keymap = "<C-Enter>",
        dismiss_keymap = "<C-Esc>",
      })
      vim.api.nvim_create_user_command("HFccComplete", function()
        require("hfcc.completion").complete()
      end, {})
      require('hfcc.completion').toggle_suggestion()
    end,
  },
}

return completion_plugins
