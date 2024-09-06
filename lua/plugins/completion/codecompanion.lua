return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>cc', group = 'codecompanion', mode = { 'n', 'v' } },
        { '<localleader>c', group = 'codecompanion', mode = { 'n', 'v' } },
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'nvim-telescope/telescope.nvim', -- Optional
      'stevearc/dressing.nvim', -- Optional: Improves the default Neovim UI
    },
    cmd = {
      'CodeCompanion',
      'CodeCompanionChat',
      'CodeCompanionActions',
      'CodeCompanionToggle',
      'CodeCompanionAdd',
    },
    keys = {
      { '<leader>cct', ':CodeCompanionToggle<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Toggle' },
      { '<leader>cc+', ':CodeCompanionAdd<cr>', mode = { 'v' }, desc = 'Code Companion Add' },
      { '<leader>cca', ':CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Actions' },
      { '<leader>ccc', ':CodeCompanionChat<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Chat' },
      { '<leader>cci', ':CodeCompanion<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Open' },
    },
    init = function() vim.cmd([[cab cc CodeCompanion]]) end,
    opts = {
      adapters = {
        openai = 'openai',
        copilot = 'copilot',
      },
      strategies = {
        chat = {
          adapter = 'copilot',
          roles = {
            llm = ' ', -- The markdown header content for the LLM's responses
            user = ' ', -- The markdown header for your questions
          },
          inline = {
            adapter = 'copilot',
          },
          agent = {
            adapter = 'copilot',
          },
        },
        adapters = {
          openai = function()
            return require('codecompanion.adapters').extend('openai', {
              schema = {
                model = {
                  api_key = 'OPENAI_API_KEY',
                  default = 'gpt-4o-mini',
                },
              },
            })
          end,
        },
      },
      display = {
        inline = { diff = { enabled = false } },
      },
    },
  },
}
