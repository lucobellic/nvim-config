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
      language = 'english',
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
            content = 'When asked to add documentation, follow these steps:\n'
              .. '1. **Identify Key Points**: Carefully read the provided code to understand its functionality.\n'
              .. '2. **Review the Documentation**: Ensure the documentation:\n'
              .. '  - Includes necessary explanations.\n'
              .. "  - Helps in understanding the code's functionality.\n"
              .. '  - Follows best practices for readability and maintainability.\n'
              .. '  - Is formatted correctly.\n\n'
              .. 'For C/C++ code: use Doxygen comments using `\\` instead of `@`.\n'
              .. 'For Python code: Use Docstring numpy-notypes format.',
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
            content = 'When asked to optimize code, follow these steps:\n'
              .. '1. **Analyze the Code**: Understand the functionality and identify potential bottlenecks.\n'
              .. '2. **Implement the Optimization**: Apply the optimizations including best practices to the code.\n'
              .. '3. **Shorten the code**: Remove unnecessary code and refactor the code to be more concise.\n'
              .. '3. **Review the Optimized Code**: Ensure the code is optimized for performance and readability. Ensure the code:\n'
              .. '  - Maintains the original functionality.\n'
              .. '  - Is more efficient in terms of time and space complexity.\n'
              .. '  - Follows best practices for readability and maintainability.\n'
              .. '  - Is formatted correctly.\n\n'
              .. 'Use Markdown formatting and include the programming language name at the start of the code block.',
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
            model = 'gpt-4.1',
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

              chat.context:add({
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
        description = 'agent mode with explicit set of tools',
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
              return 'You are in agent mode:\n'
                .. 'Use tools to answer user request using @{cmd_runner}\n'
                .. '- Do NOT use `grep`\n'
                .. '- Search content and patterns using `fzf`\n'
                .. '- Do NOT use `find`\n'
                .. '- Search files with `fd`'
            end,
          },
        },
      },
      ['Split Commits'] = {
        strategy = 'chat',
        description = 'agent mode with explicit set of tools',
        opts = {
          index = 22,
          is_default = false,
          short_name = 'commits',
          is_slash_cmd = true,
          auto_submit = false,
        },
        prompts = {
          {
            role = 'user',
            contains_code = true,
            content = function()
              local current_branch = vim.fn.system('git rev-parse --abbrev-ref HEAD')
              local logs = vim.fn.system('git log --pretty=format:"%s%n%b" -n 50')
              local commit_history = 'Commit history for branch ' .. current_branch .. ':\n' .. logs .. '\n\n'
              local staged_changes = 'Staged files:\n' .. vim.fn.system('git diff --cached --name-only')
              local prompt = '<prompt>' .. commit_history .. staged_changes .. '</prompt> \n\n'
              local task = 'You are an expert Git assistant.\n'
                .. 'Your task is to help the user create well-structured and conventional commits from their currently staged changes.\n\n'
                .. 'Based on the provided commit logs and branch name, first, infer the established commit message convention\n'
                .. 'Next, use the staged changes to determine the logical grouping of changes and generate appropriate commit messages.\n\n'
                .. 'Your primary goal is to analyze these staged changes and determine if they should be split into multiple logical and separate commits.\n'
                .. 'If the staged changes are empty or too trivial for a meaningful commit, please state that.\n\n'
                .. 'Use @{cmd_runner} to execute git commands for staging and un-staging files to group staged changes into meaningful commits when necessary.'
              return prompt .. task
            end,
          },
        },
      },
      ['Gitlab MR Notes'] = {
        strategy = 'chat',
        description = 'Get the unresolved comments of the current MR',
        opts = {
          index = 23,
          is_default = false,
          short_name = 'glab_mr_notes',
          is_slash_cmd = true,
          auto_submit = false,
        },
        prompts = {
          {
            role = 'user',
            contains_code = true,
            content = function()
              local notes = require('util.glab.notes').get_unresolved_discussions()
              return 'Here is a list of notes from Pull Request:\n' .. notes .. '\n'
            end,
          },
        },
      },
      ['qflist'] = {
        strategy = 'chat',
        description = 'Send errors to qflist and diagnostics',
        opts = {
          index = 24,
          is_default = false,
          short_name = 'qflist',
          is_slash_cmd = true,
          auto_submit = false,
        },
        prompts = {
          {
            role = 'user',
            contains_code = true,
            content = function()
              local content =
                'Create a neovim command line for `:` to send the current errors to qflist and diagnostics using neovim api.\n'
              local example = [[
                :lua do local ns = vim.api.nvim_create_namespace('review');

                  -- For each files:
                  local bufnr = vim.fn.bufnr('/full/path/to/your/file.txt');
                  if bufnr ~= -1 then
                    local diagnostics = {{bufnr=bufnr, lnum=324, col=0, message='This is the ErrorMessage', severity=vim.diagnostic.severity.ERROR}};
                    vim.diagnostic.set(ns, bufnr, diagnostics);
                    vim.fn.setqflist(vim.diagnostic.toqflist(diagnostics), 'a');
                  end
                end
                ]]
              return content .. '\nExample:\n' .. example:gsub('\n', ' '):gsub(' +', ' ')
            end,
          },
        },
      },
    },
  },
}
