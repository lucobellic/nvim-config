local function send_buffer_to_chat(bufnr)
  CodeCompanion = require('codecompanion')

  local chat = CodeCompanion.last_chat()
  if not chat then
    chat = CodeCompanion.chat()
  end

  chat:add_buf_message({
    role = 'user',
    content = '#{buffer:' .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t') .. '}',
  })
  chat.ui:open()
end

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
    cond = vim.env.KITTY_SCROLLBACK_NVIM ~= 'true' and not vim.g.vscode,
    version = '18.*',
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
      'CodeCompanionClearInlineExtmarks',
    },
    keys = {
      { '<leader>ae', ':CodeCompanionChat Add<cr>', mode = { 'v' }, desc = 'Code Companion Add' },
      {
        '<leader>ab',
        function() send_buffer_to_chat(vim.api.nvim_get_current_buf()) end,
        desc = 'Code Companion Send Buffer',
      },
      { '<leader>aa', ':CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Actions' },
      { '<leader>ac', ':CodeCompanionChat<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Chat' },
      { '<leader>ad', ':CodeCompanion /doc<cr>', mode = { 'v' }, desc = 'Code Companion Documentation' },
      { '<leader>af', ':CodeCompanion /fix<cr>', mode = { 'v' }, desc = 'Code Companion Fix' },
      { '<leader>ag', ':CodeCompanion /scommit<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Commit' },
      { '<leader>ai', ':CodeCompanion /agent<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Inline Prompt' },
      { '<leader>al', ':CodeCompanion /lsp<cr>', mode = { 'n', 'v' }, desc = 'Code Companion LSP' },
      {
        '<leader>an',
        function() require('codecompanion').chat() end,
        mode = { 'n' },
        desc = 'Code Companion New Chat',
      },
      { '<leader>ap', ':CodeCompanion /pr<cr>', mode = { 'n' }, desc = 'Code Companion PR' },
      { '<leader>ar', ':CodeCompanion /optimize<cr>', mode = { 'v' }, desc = 'Code Companion Refactor' },
      { '<leader>as', ':CodeCompanion /grammar<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Grammar' },
      { '<leader>aS', ':CodeCompanion /spell<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Spell' },
      { '<leader>at', ':CodeCompanion /tests<cr>', mode = { 'v' }, desc = 'Code Companion Generate Test' },
      {
        '<leader>at',
        ':CodeCompanion #{explain terminal error}<cr>',
        mode = { 'n' },
        desc = 'Code Companion Explain Terminal Error',
      },
      {
        '<C-l>',
        function()
          require('codecompanion').inline_accept_word()
        end,
        desc = 'Copilot accept word',
        mode = 'i',
      },

    },
    init = function()
      vim.g.codecompanion_yolo_mode = true
      vim.cmd([[cab cc CodeCompanion]])
      vim.cmd([[cab ccc CodeCompanionChat]])
    end,
    opts = {
      require_approval_before = false,
      interactions = {
        chat = {
          opts = {
            goto_file_action = 'edit',
            system_prompt = function()
              return 'You are a world class programming AI assistant. Help the user with their coding tasks.'
            end,
          },
          roles = {
            user = '',
            llm = function(adapter) return '  ' .. adapter.formatted_name end,
          },
          keymaps = {
            clear = { modes = { n = '<C-x>' } },
            next_chat = { modes = { n = '<A-l>' } },
            previous_chat = { modes = { n = '<A-h>' } },
            regenerate = { modes = { n = '<localleader>r' } },
            stop = { modes = { n = 'q' } },
            codeblock = { modes = { n = '<localleader>c' } },
            yank_code = { modes = { n = '<localleader>y' } },
            sync_all = { modes = { n = '<localleader>p' } },
            sync_diff = { modes = { n = '<localleader>w' } },
            change_adapter = { modes = { n = '<localleader>a' } },
            fold_code = { modes = { n = '<localleader>f' } },
            debug = { modes = { n = '<localleader>d' } },
            system_prompt = { modes = { n = '<localleader>s' } },
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
