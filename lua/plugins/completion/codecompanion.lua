local chat_adapter = 'copilot'
local agent_adapter = 'copilot'
local inline_adapter = 'copilot'

local function no_system_prompt_handler()
  return {
    ---Handler to remove system prompt from messages
    ---@param self CodeCompanion.Adapter
    ---@param messages table
    form_messages = function(self, messages)
      return {
        messages = vim
          .iter(messages)
          :filter(function(message) return not (message.role and message.role == 'system') end)
          :totable(),
      }
    end,
  }
end

---@param branch string
local function get_changed_files(branch)
  local output = vim.fn.system('git diff --name-only ' .. branch .. ' | xargs -I {} realpath {}')
  local files = {}
  for line in output:gmatch('([^\r\n]+)') do
    table.insert(files, line)
  end
  return files
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
      'nvim-telescope/telescope.nvim', -- Optional
      'stevearc/dressing.nvim', -- Optional: Improves the default Neovim UI
      'echasnovski/mini.pick', -- Optional: mini_pick provider
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
      { '<leader>ab', ':CodeCompanion /buffer<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Buffer' },
      { '<leader>ac', ':CodeCompanionChat<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Chat' },
      { '<leader>ad', ':CodeCompanion /doc<cr>', mode = { 'v' }, desc = 'Code Companion Documentation' },
      { '<leader>ae', ':CodeCompanion /explain<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Explain' },
      { '<leader>af', ':CodeCompanion /fix<cr>', mode = { 'v' }, desc = 'Code Companion Fix' },
      { '<leader>ag', ':CodeCompanion /scommit<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Commit' },
      { '<leader>ai', ':CodeCompanion<cr>', mode = { 'n', 'v' }, desc = 'Code Companion Inline Prompt' },
      { '<leader>ai', ':CodeCompanion /buffer<cr>', mode = { 'n' }, desc = 'Code Companion Inline Prompt' },
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
      log_level = 'DEBUG',
      adapters = {
        copilot = function()
          return require('codecompanion.adapters').extend('copilot', {
            schema = {
              model = {
                default = 'claude-3.5-sonnet',
                choices = {
                  ['o1'] = { handler = no_system_prompt_handler() },
                  ['o1-mini'] = { handler = no_system_prompt_handler() },
                  'claude-3.5-sonnet',
                  'gpt-4o',
                  'gpt-4o-mini',
                },
              },
              max_tokens = {
                default = 8192,
              },
            },
          })
        end,
        copilot_preview = require('plugins.completion.codecompanion.copilot_preview').get_adapter,
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            schema = {
              model = {
                default = 'deepseek-coder-v2',
                choices = {
                  'deepseek-coder-v2',
                  'deepseek-r1',
                },
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = chat_adapter,
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
          slash_commands = {
            ['buffer'] = {
              opts = {
                provider = 'telescope',
              },
            },
            ['file'] = {
              opts = {
                provider = 'telescope',
              },
            },
            ['terminals'] = {
              callback = function() return 'Custom context or data' end,
              description = 'Insert terminal output',
              opts = {
                provider = 'telescope',
              },
            },
          },
        },
        inline = {
          adapter = inline_adapter,
        },
        agent = {
          adapter = agent_adapter,
        },
      },
      display = {
        diff = { enabled = false },
        chat = {
          show_header_separator = false,
          show_settings = false,
        },
        action_palette = { provider = 'telescope' },
      },
      prompt_library = {
        -- Prefer buffer selection in chat instead of inline
        ['Buffer selection'] = {
          strategy = 'chat',
          opts = {
            auto_submit = false,
          },
        },
        ['Generate a Commit Message for Staged Files'] = {
          strategy = 'chat',
          description = 'staged file commit messages',
          opts = {
            index = 15,
            is_default = false,
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
            is_default = false,
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
            is_default = false,
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
            is_default = false,
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
                  .. vim.fn.system('git diff $(git merge-base HEAD develop)...HEAD')
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
            is_default = false,
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
        ['Bug Finder'] = {
          strategy = 'chat',
          description = 'Find potential bugs from the provided diff changes',
          opts = {
            index = 20,
            is_default = false,
            short_name = 'bugs',
            is_slash_cmd = true,
            auto_submit = true,
          },
          prompts = {
            {
              role = 'user',
              contains_code = true,
              content = function()
                local question = '<question>\n'
                  .. 'Check if there is any bugs that have been introduced from the provided diff changes.\n'
                  .. 'Perform a complete analysis and do not stop at first issue found.\n'
                  .. '</question>'

                local branch = '$(git merge-base HEAD develop)...HEAD'
                local diff = '\n\n```diff\n' .. vim.fn.system('git diff ' .. branch) .. '\n```\n'

                local included_files = get_changed_files(branch)
                local file_path_test = '\nThe list of the modified files are:\n'
                  .. '\n<files>\n'
                  .. table.concat(included_files, '\n')
                  .. '\n</files>\n'

                -- use @files tool to enable LLM to read files with changes
                return '@files\n' .. question .. diff .. file_path_test
              end,
            },
          },
        },
      },
    },
    config = function(_, opts)
      require('codecompanion').setup(opts)

      -- create a folder to store our chats
      local Path = require('plenary.path')
      local data_path = vim.fn.stdpath('data')
      local save_folder = Path:new(data_path, 'cc_saves')
      if not save_folder:exists() then
        save_folder:mkdir({ parents = true })
      end

      -- telescope picker for our saved chats
      vim.api.nvim_create_user_command('CodeCompanionLoad', function()
        local t_builtin = require('telescope.builtin')
        local t_actions = require('telescope.actions')
        local t_action_state = require('telescope.actions.state')

        local function start_picker()
          t_builtin.find_files({
            prompt_title = 'Saved CodeCompanion Chats | <c-d>: delete',
            cwd = save_folder:absolute(),
            attach_mappings = function(_, map)
              map('i', '<c-d>', function(prompt_bufnr)
                local selection = t_action_state.get_selected_entry()
                local filepath = selection.path or selection.filename
                os.remove(filepath)
                t_actions.close(prompt_bufnr)
                start_picker()
              end)
              return true
            end,
          })
        end
        start_picker()
      end, {})

      -- save current chat, `CodeCompanionSave foo bar baz` will save as 'foo-bar-baz.md'
      vim.api.nvim_create_user_command('CodeCompanionSave', function(opts)
        local codecompanion = require('codecompanion')
        local success, chat = pcall(function() return codecompanion.buf_get_chat(0) end)
        if not success or chat == nil then
          vim.notify('CodeCompanionSave should only be called from CodeCompanion chat buffers', vim.log.levels.ERROR)
          return
        end
        if #opts.fargs == 0 then
          vim.notify('CodeCompanionSave requires at least 1 arg to make a file name', vim.log.levels.ERROR)
        end
        local save_name = table.concat(opts.fargs, '-') .. '.md'
        local save_path = Path:new(save_folder, save_name)
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        save_path:write(table.concat(lines, '\n'), 'w')
      end, { nargs = '*' })
    end,
  },
}
