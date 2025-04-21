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
  'olimorris/codecompanion.nvim',
  opts = {
    opts = {
      system_prompt = function()
        return ([[
          Use Markdown formatting in your answers:
            - Include the programming language name at the start of each Markdown code block.
            - Avoid including line numbers in code blocks.
            - Only return code that's directly relevant to the task at hand.
            - Avoid using H1 and H2 headers in your responses.

          Call tools one by one before preparing all steps to call tools.
        ]]):gsub('^ +', '', 1):gsub('\n +', '\n')
      end,
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
        strategy = 'inline',
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
                2. **Review the Documentation**: Ensure the documentation:
                  - Includes necessary explanations.
                  - Helps in understanding the code's functionality.
                  - Follows best practices for readability and maintainability.
                  - Is formatted correctly.

                For C/C++ code: use Doxygen comments using `\` instead of `@`.
                For Python code: Use Docstring numpy-notypes format.]],
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
          adapter = {
            name = 'copilot',
            model = 'gpt-4o',
          },
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
                .. 'If available, provide absolute file path and line number for code snippets.\n'
                .. '</question>'

              local branch = '$(git merge-base HEAD origin/develop)...HEAD'
              local changes = 'changes.diff'
              vim.fn.system('git diff --unified=10000 ' .. branch .. ' > ' .. changes)

              --- @type CodeCompanion.Chat
              local chat = require('codecompanion').buf_get_chat(vim.api.nvim_get_current_buf())
              local path = vim.fn.getcwd() .. '/' .. changes
              local id = '<file>' .. changes .. '</file>'
              local lines = vim.fn.readfile(path)
              local content = table.concat(lines, '\n')

              chat:add_message({
                role = 'user',
                content = 'git diff content from ' .. path .. ':\n' .. content,
              }, { reference = id, visible = false })

              chat.references:add({
                id = id,
                path = path,
                source = '',
              })

              return question
            end,
          },
        },
      },
      ['Agent Mode'] = {
        strategy = 'chat',
        description = 'Agent mode with explicit set of tools',
        opts = {
          index = 21,
          is_default = false,
          short_name = 'agent',
          is_slash_cmd = true,
          auto_submit = false,
        },
        prompts = {
          {
            role = 'user',
            contains_code = true,
            content = function()
              return ([[
                You are in agent mode:
                Use tools to answer user request using @full_stack_dev
                  - Use `fzf` instead of `grep` to search for patterns in files.
                  - Use `fd` instead of `find` to locate files or directories.
                Call tools one by one before preparing all steps to call tools.
                Check tools usage before using them several times.
              ]]):gsub('^ +', '', 1):gsub('\n +', '\n')
            end,
          },
        },
      },
    },
  },
}
