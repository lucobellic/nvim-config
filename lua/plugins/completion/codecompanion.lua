local chat_adapter = 'copilot'
local agent_adapter = 'copilot'
local inline_adapter = 'copilot_inline'

if vim.g.vscode then
  local vscode = require('vscode')
  local is_cursor = vscode.eval('return vscode.env.appName.includes("Cursor")')
  if is_cursor then
    vim.keymap.set(
      'n',
      '<leader>;a',
      function() vscode.action('composerMode.agent') end,
      { desc = 'Cursor Toggle Chat' }
    )
    vim.keymap.set(
      'v',
      '<leader>ai',
      function() vscode.action('aipopup.action.modal.generate') end,
      { desc = 'Cursor Inline Prompt' }
    )
    vim.keymap.set(
      'v',
      '<leader>ae',
      function() vscode.action('aichat.insertselectionintochat') end,
      { desc = 'Cursor Add Selection To Chat' }
    )
  else
    vim.keymap.set(
      'n',
      '<leader>;i',
      function() vscode.action('workbench.panel.chatEditing') end,
      { desc = 'Toggle composer view' }
    )
    vim.keymap.set(
      'n',
      '<leader>;a',
      function() vscode.action('workbench.panel.chat') end,
      { desc = 'Copilot Toggle Chat' }
    )
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>ai',
      function() vscode.action('inlineChat.start') end,
      { desc = 'Copilot Inline Prompt' }
    )
    vim.keymap.set({ 'n', 'v' }, '<leader>ae', function()
      -- vscode.action('github.copilot.chat.attachSelection')
      vscode.action('github.copilot.edits.attachSelection')
    end, { desc = 'Copilot Add Selection To Chat' })
  end
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
    enabled = vim.env.KITTY_SCROLLBACK_NVIM ~= 'true',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'ravitemer/mcphub.nvim',
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
    },
    init = function()
      vim.cmd([[cab cc CodeCompanion]])
      vim.cmd([[cab ccc CodeCompanionChat]])
    end,
    opts = {
      system_prompt = function() return '' end,
      adapters = require('plugins.completion.codecompanion.adapters'),
      strategies = {
        chat = {
          adapter = chat_adapter,
          -- roles = {
          --   llm = ' ', -- The markdown header content for the LLM's responses
          --   user = ' ', -- The markdown header for your questions
          -- },
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
          slash_commands = require('plugins.completion.codecompanion.slash_commands'),
        },
        inline = { adapter = inline_adapter },
        agent = { adapter = agent_adapter },
      },
      display = {
        diff = { enabled = false },
        chat = {
          show_header_separator = false,
          show_settings = false,
        },
        action_palette = { provider = 'default' },
      },
      prompt_library = require('plugins.completion.codecompanion.prompt_library'),
    },
    config = function(_, opts)
      -- Configure vectorcode integrations
      local ok, vectorcode_integrations = pcall(require, 'vectorcode.integrations')

      if ok then
        opts = vim.tbl_deep_extend('force', opts, {
          strategies = {
            chat = {
              slash_commands = {
                codebase = vectorcode_integrations.codecompanion.chat.make_slash_command(),
              },
              tools = {
                vectorcode = {
                  description = 'Run VectorCode to retrieve the project context.',
                  callback = vectorcode_integrations.codecompanion.chat.make_tool(),
                },
              },
            },
          },
        })
      end

      -- Configure mcphub integrations
      local ok, mcphub_codecompanion = pcall(require, 'mcphub.extensions.codecompanion')
      if ok then
        mcphub_codecompanion.output.success = function(self, action, output)
          local result = output[1]
          local action_name = action._attr.type
          self.chat:add_buf_message({
            role = 'llm',
            content = 'The ' .. action_name .. ' call was successful with the following result\n' .. result,
          })
        end

        opts = vim.tbl_deep_extend('force', opts, {
          strategies = {
            chat = {
              tools = {
                ['mcp'] = {
                  description = 'Call tools and resources from the MCP Servers',
                  callback = mcphub_codecompanion,
                  opts = {
                    requires_approval = true,
                  },
                },
              },
            },
          },
        })
      end

      vim.g.codecompanion_auto_tool_mode = true
      require('codecompanion').setup(opts)
    end,
  },
}
