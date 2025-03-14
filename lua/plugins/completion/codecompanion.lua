local chat_adapter = 'copilot'
local agent_adapter = 'copilot'
local inline_adapter = 'copilot'


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
    -- event = 'VeryLazy',
    cmd = {
      'CodeCompanion',
      'CodeCompanionChat',
      'CodeCompanionActions',
      'CodeCompanionAdd',
    },
    keys = {
      { '<leader>a+', ':CodeCompanionChat Add<cr>', mode = { 'v' }, desc = 'Code Companion Add' },
      { '<leader>aa', ':CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Actions' },
      { '<leader>ac', ':CodeCompanionChat<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Chat' },
      { '<leader>ad', ':CodeCompanion /doc<cr>', mode = { 'v' }, desc = 'Code Companion Documentation' },
      { '<leader>ae', ':CodeCompanion /explain<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Explain' },
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
            clear = {
              modes = {
                n = '<C-x>',
              },
              index = 5,
              callback = 'keymaps.clear',
              description = 'Clear Chat',
            },
            next_chat = {
              modes = {
                n = '>>',
              },
              index = 8,
              callback = 'keymaps.next_chat',
              description = 'Next Chat',
            },
            previous_chat = {
              modes = {
                n = '<<',
              },
              index = 9,
              callback = 'keymaps.previous_chat',
              description = 'Previous Chat',
            },
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
