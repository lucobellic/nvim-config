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
      { '<leader>a+', ':CodeCompanionAdd<cr>', mode = { 'v' }, desc = 'Code Companion Add' },
      { '<leader>aa', ':CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Actions' },
      { '<leader>ab', ':CodeCompanion /buffer<cr>', mode = { 'n' }, desc = 'Code Companion Send Buffer To Chat' },
      { '<leader>ac', ':CodeCompanionChat<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Chat' },
      { '<leader>ad', ':CodeCompanion /doc<cr>', mode = { 'v' }, desc = 'Code Companion Documentation' },
      { '<leader>ae', ':CodeCompanion /explain<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Explain' },
      { '<leader>af', ':CodeCompanion /fix<cr>', mode = { 'v' }, desc = 'Code Companion Fix' },
      { '<leader>ag', ':CodeCompanion /scommit<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Commit' },
      { '<leader>ai', ':CodeCompanion<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Inline Prompt'},
      { '<leader>al', ':CodeCompanion /lsp<cr>', mode = { 'n', 'v' }, desc = 'Code Companion LSP' },
      { '<leader>ar', ':CodeCompanion /optimize<cr>', mode = { 'v' }, desc = 'Code Companion Refactor' },
      { '<leader>at', ':CodeCompanion /tests<cr>', mode = { 'v' }, desc = 'Code Companion Generate test' },
      { '<leader>at', ':CodeCompanionToggle<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Toggle' },
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
      default_prompts = {
        ['Generate a Commit Message for Staged Files'] = {
          strategy = 'chat',
          description = 'staged file commit messages',
          opts = {
            index = 10,
            default_prompt = true,
            mapping = '<localLeader>cg',
            slash_cmd = 'scommit',
            auto_submit = true,
          },
          prompts = {
            {
              role = 'user',
              contains_code = true,
              content = function()
                return 'You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:'
                  .. '\n\n```\n'
                  .. vim.fn.system('git diff --staged')
                  .. '\n```'
              end,
            },
          },
        },
        ['Add Documentation'] = {
          strategy = 'inline',
          description = 'Add documentation to the selected code',
          opts = {
            index = 11,
            default_prompt = true,
            mapping = '<localLeader>cd',
            modes = { 'v' },
            slash_cmd = 'doc',
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[
                When asked to add documentation, follow these steps:
                1. **Identify Key Points**: Carefully read the provided code to understand its functionality.
                2. **Plan the Documentation**: Describe the key points to be documented in pseudocode, detailing each step.
                3. **Implement the Documentation**: Write the accompanying documentation in the same file or a separate file.
                4. **Review the Documentation**: Ensure that the documentation is comprehensive and clear. Ensure the documentation:
                  - Includes necessary explanations.
                  - Helps in understanding the code's functionality.
                  - Add parameters, return values, and exceptions documentation.
                  - Follows best practices for readability and maintainability.
                  - Is formatted correctly.

                Use Markdown formatting and include the programming language name at the start of the code block.]],
              opts = {
                visible = false,
              },
            },
            {
              role = 'user',
              content = function(context)
                local code = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)

                return 'Please document the selected code:\n\n```' .. context.filetype .. '\n' .. code .. '\n```\n\n'
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ['Refactor'] = {
          strategy = 'chat',
          description = 'Refactor the selected code for readability, maintainability and performances',
          opts = {
            index = 12,
            default_prompt = true,
            mapping = '<localLeader>cr',
            modes = { 'v' },
            slash_cmd = 'refactor',
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = 'system',
              content = [[
                When asked to optimize code, follow these steps:
                1. **Analyze the Code**: Understand the functionality and identify potential bottlenecks.
                2. **Implement the Optimization**: Apply the optimizations including best practices to the code.
                3. **Shorthen the code**: Remove unnecessary code and refactor the code to be more concise.
                3. **Review the Optimized Code**: Ensure the code is optimized for performance and readability. Ensure the code:
                  - Maintains the original functionality.
                  - Is more efficient in terms of time and space complexity.
                  - Follows best practices for readability and maintainability.
                  - Is formatted correctly.

                Use Markdown formatting and include the programming language name at the start of the code block.]],
              opts = {
                visible = false,
              },
            },
            {
              role = 'user',
              content = function(context)
                local code = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)

                return 'Please optimize the selected code:\n\n```' .. context.filetype .. '\n' .. code .. '\n```\n\n'
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
      },
    },
  },
}
