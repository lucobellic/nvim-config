return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>a', group = 'codecompanion', mode = { 'n', 'v' } },
        { '<localleader>a', group = 'codecompanion', mode = { 'n', 'v' } },
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    enabled = vim.env.KITTY_SCROLLBACK_NVIM ~= 'true',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      { 'ravitemer/mcphub.nvim', optional = true },
    },
    cmd = {
      'CodeCompanion',
      'CodeCompanionChat',
      'CodeCompanionActions',
      'CodeCompanionAdd',
    },
    keys = {
      { '<leader>ae', ':CodeCompanionChat Add<cr>', mode = { 'v' }, desc = 'Code Companion Add' },
      { '<leader>aa', ':CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Actions' },
      { '<leader>ac', ':CodeCompanionChat<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Chat' },
      { '<leader>ad', ':CodeCompanion /doc<cr>', mode = { 'v' }, desc = 'Code Companion Documentation' },
      { '<leader>af', ':CodeCompanion /fix<cr>', mode = { 'v' }, desc = 'Code Companion Fix' },
      { '<leader>ag', ':CodeCompanion /scommit<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Commit' },
      { '<leader>ai', ':CodeCompanion<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Inline Prompt' },
      { '<leader>al', ':CodeCompanion /lsp<cr>', mode = { 'n', 'v' }, desc = 'Code Companion LSP' },
      {
        '<leader>an',
        function() require('codecompanion').chat() end,
        mode = { 'n' },
        desc = 'Code Companion New Chat',
      },
      { '<leader>ap', ':CodeCompanion /pr<cr>', mode = { 'n' }, desc = 'Code Companion PR' },
      { '<leader>ar', ':CodeCompanion /optimize<cr>', mode = { 'v' }, desc = 'Code Companion Refactor' },
      { '<leader>as', ':CodeCompanion /spell<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Spell' },
      { '<leader>at', ':CodeCompanion /tests<cr>', mode = { 'v' }, desc = 'Code Companion Generate Test' },
      {
        '<leader>at',
        ':CodeCompanion #{explain terminal error}<cr>',
        mode = { 'n' },
        desc = 'Code Companion Explain Terminal Error',
      },
    },
    init = function()
      vim.g.codecompanion_auto_tool_mode = true
      vim.cmd([[cab cc CodeCompanion]])
      vim.cmd([[cab ccc CodeCompanionChat]])
    end,
    opts = {
      strategies = {
        chat = {
          opts = { goto_file_action = 'edit' },
          roles = {
            user = '',
            llm = function(adapter) return '  ' .. adapter.formatted_name end,
          },
          keymaps = {
            clear = { modes = { n = '<C-x>' } },
            next_chat = { modes = { n = '>>' } },
            previous_chat = { modes = { n = '<<' } },
            regenerate = { modes = { n = '<localleader>r' } },
            stop = { modes = { n = 'q' } },
            codeblock = { modes = { n = '<localleader>c' } },
            yank_code = { modes = { n = '<localleader>y' } },
            pin = { modes = { n = '<localleader>p' } },
            watch = { modes = { n = '<localleader>w' } },
            change_adapter = { modes = { n = '<localleader>a' } },
            fold_code = { modes = { n = '<localleader>f' } },
            debug = { modes = { n = '<localleader>d' } },
            system_prompt = { modes = { n = '<localleader>s' } },
            auto_tool_mode = { modes = { n = '<localleader>ta' } },
          },
          tools = {
            opts = {
              auto_submit_errors = true, -- Send any errors to the LLM automatically
              auto_submit_success = true, -- Send any successful output to the LLM automatically
            },
          },
        },
      },
      display = {
        diff = { enabled = false },
        chat = {
          show_header_separator = false,
          show_settings = false, -- do not show settings to allow model change with shortcut
        },
        action_palette = { provider = 'default' },
      },
    },
    config = function(_, opts)
      require('codecompanion').setup(opts)
      require('plugins.codecompanion.utils.extmarks').setup()
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    optional = true,
    opts = function(_, opts)
      vim.treesitter.language.register('markdown', 'codecompanion')
      return opts
    end,
  },
}
