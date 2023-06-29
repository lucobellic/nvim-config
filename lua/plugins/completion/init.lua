local completion_plugins = {
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      {
        'onsails/lspkind.nvim',
        config = function()
          require('lspkind').init({
            symbol_map = {
              Copilot = "",
            },
          })
        end
      }
    },
    opts = require('plugins.completion.cmp'),
  },

  { 'echasnovski/mini.pairs', enabled = false },

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
