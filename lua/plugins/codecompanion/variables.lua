return {
  'olimorris/codecompanion.nvim',
  opts = {
    strategies = {
      chat = {
        variables = {
          ['explain terminal error'] = {
            callback = function()
              local overseer = require('overseer')
              local constants = require('overseer.constants')

              ---@type overseer.Task[]
              local failed_tasks = overseer.list_tasks({ status = constants.STATUS.FAILURE })
              local first_failed_task = vim.iter(failed_tasks):last() --- @type overseer.Task | nil

              if first_failed_task then
                local lines = vim.api.nvim_buf_get_lines(first_failed_task.strategy.term.bufnr, 0, -1, false)
                local context = 'Explain the error from the command '
                  .. first_failed_task.cmd
                  .. ':\n'
                  .. table.concat(lines, '\n')
                  .. '\n\n'

                --- @type CodeCompanion.Chat
                local chat = require('codecompanion').buf_get_chat(vim.api.nvim_get_current_buf())
                chat:add_message({
                  role = 'user',
                  content = context,
                }, { tag = 'variable', visible = false })
              end
            end,
            description = 'Explain the content of the latest failed task',
            opts = {
              contains_code = false,
            },
          },
        },
      },
    },
  },
}
