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
            .. 'If available, provide absolute file path and line number for code snippets.\n'
            .. '</question>'

          local branch = '$(git merge-base HEAD develop)...HEAD'
          local diff = '\n\n```diff\n' .. vim.fn.system('git diff ' .. branch) .. '\n```\n'

          local included_files = get_changed_files(branch)
          --- @type CodeCompanion.Chat
          local current_chat = require('codecompanion').buf_get_chat(vim.api.nvim_get_current_buf())

          vim.iter(included_files):filter(function(path) return not path:find('Not a valid object name') end):each(
            function(path)
              current_chat.references:add({
                id = vim.fn.fnamemodify(path, ':t'),
                path = path,
                source = 'codecompanion.strategies.chat.slash_commands.bugs',
              })
            end
          )

          return question .. diff
        end,
      },
    },
  },
}
