return {
  'jackMort/ChatGPT.nvim',
  event = 'VeryLazy',
  keys = {
    { "<leader>ce", function() require('chatgpt').edit_with_instructions() end, desc = "ChatGPT edit with instructions" },
    { "<leader>cg", ":ChatGPT<cr>",                                             desc = "ChatGPT" }
  },
  opts = {
    chat = {
      keymaps = {
        close = { "<C-c>", "<C-q>"},
        yank_last = "<C-y>",
        yank_last_code = "<C-k>",
        scroll_up = "<C-u>",
        scroll_down = "<C-d>",
        toggle_settings = "<C-o>",
        new_session = "<C-n>",
        cycle_windows = "<Tab>",
        select_session = "<Space>",
        rename_session = "r",
        delete_session = "d",
      },
    }
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim'
  },
}
