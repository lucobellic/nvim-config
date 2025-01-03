local adapter = 'copilot'
-- local adapter = 'openai'
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
    -- 'olimorris/codecompanion.nvim',
    'lucobellic/codecompanion.nvim',
    branch = 'hotfix/parsing',
    enabled = vim.env.KITTY_SCROLLBACK_NVIM ~= 'true',
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
      'CodeCompanionAdd',
    },
    keys = {
      { '<leader>a+', ':CodeCompanionChat Add<cr>', mode = { 'v' }, desc = 'Code Companion Add' },
      { '<leader>aa', ':CodeCompanionActions<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Actions' },
      { '<leader>ab', ':CodeCompanion /buffer<cr>', mode = { 'n' }, desc = 'Code Companion Buffer' },
      { '<leader>ac', ':CodeCompanionChat<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Chat' },
      { '<leader>ad', ':CodeCompanion /doc<cr>', mode = { 'v' }, desc = 'Code Companion Documentation' },
      { '<leader>ae', ':CodeCompanion /explain<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Explain' },
      { '<leader>af', ':CodeCompanion /fix<cr>', mode = { 'v' }, desc = 'Code Companion Fix' },
      { '<leader>ag', ':CodeCompanion /scommit<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Commit' },
      { '<leader>ai', ':CodeCompanion<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Inline Prompt' },
      { '<leader>al', ':CodeCompanion /lsp<cr>', mode = { 'n', 'v' }, desc = 'Code Companion LSP' },
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
      -- opts = { log_level = 'TRACE' },
      adapters = {
        copilot = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = {
                default = 'gpt-4o',
                choices = {
                  'claude-3.5-sonnet',
                  'gpt-4o',
                  'gpt-4o-mini',
                },
              },
            },
          })
        end,
        copilot_preview = require('plugins.completion.codecompanion.copilot_preview').get_adapter,
      },
      strategies = {
        chat = {
          adapter = adapter,
          roles = {
            llm = ' ', -- The markdown header content for the LLM's responses
            user = ' ', -- The markdown header for your questions
          },
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
                n = '>',
              },
              index = 8,
              callback = 'keymaps.next_chat',
              description = 'Next Chat',
            },
            previous_chat = {
              modes = {
                n = '<',
              },
              index = 9,
              callback = 'keymaps.previous_chat',
              description = 'Previous Chat',
            },
          },
        },
        inline = {
          adapter = adapter,
        },
        agent = {
          adapter = adapter,
        },
      },
      display = { diff = { enabled = false } },
      prompt_library = {
        ['Generate a Commit Message for Staged Files'] = {
          strategy = 'chat',
          description = 'staged file commit messages',
          opts = {
            index = 15,
            is_default = true,
            is_slash_cmd = true,
            short_name = 'scommit',
            auto_submit = true,
          },
          prompts = {
            {
              role = 'user',
              contains_code = true,
              content = function()
                return 'You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:'
                  .. '\n\n```diff\n'
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
            index = 16,
            is_default = true,
            modes = { 'v' },
            short_name = 'doc',
            is_slash_cmd = true,
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
            index = 17,
            is_default = true,
            modes = { 'v' },
            short_name = 'refactor',
            is_slash_cmd = true,
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
                3. **Shorten the code**: Remove unnecessary code and refactor the code to be more concise.
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
        ['PullRequest'] = {
          strategy = 'chat',
          description = 'Generate a Pull Request message description',
          opts = {
            index = 18,
            is_default = true,
            short_name = 'pr',
            is_slash_cmd = true,
            auto_submit = true,
          },
          prompts = {
            {
              role = 'user',
              contains_code = true,
              content = function()
                return 'You are an expert at writing detailed and clear pull request descriptions.'
                  .. 'Please create a pull request message following standard convention from the provided diff changes.'
                  .. 'Ensure the title, description, type of change, checklist, related issues, and additional notes sections are well-structured and informative.'
                  .. '\n\n```diff\n'
                  .. vim.fn.system('git diff $(git merge-base HEAD main)...HEAD')
                  .. '\n```'
              end,
            },
          },
        },
        ['Spell'] = {
          strategy = 'inline',
          description = 'Correct grammar and reformulate',
          opts = {
            index = 19,
            is_default = true,
            short_name = 'spell',
            is_slash_cmd = true,
            auto_submit = true,
          },
          prompts = {
            {
              role = 'user',
              contains_code = false,
              content = function(context)
                local text = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)
                return 'Correct grammar and reformulate:\n\n' .. text
              end,
            },
          },
        },
      },
    },
  },
}
