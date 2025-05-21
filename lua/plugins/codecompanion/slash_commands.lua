return {
  'olimorris/codecompanion.nvim',
  opts = {
    strategies = {
      chat = {
        slash_commands = {
          ['buffer'] = {
            opts = {
              provider = 'snacks',
            },
          },
          ['file'] = {
            opts = {
              provider = 'snacks',
            },
          },
          ['terminal'] = {
            ---@param chat CodeCompanion.Chat
            callback = function(chat)
              Snacks.picker.buffers({
                title = 'Terminals',
                hidden = true,
                actions = {
                  ---@param picker snacks.Picker
                  add_to_chat = function(picker)
                    picker:close()
                    local items = picker:selected({ fallback = true })
                    vim.iter(items):each(function(item)
                      local id = '<buf>' .. chat.references:make_id_from_buf(item.buf) .. '</buf>'
                      local lines = vim.api.nvim_buf_get_lines(item.buf, 0, -1, false)
                      local content = table.concat(lines, '\n')

                      chat:add_message({
                        role = 'user',
                        content = 'Terminal content from buffer ' .. item.buf .. ' (' .. item.file .. '):\n' .. content,
                      }, { reference = id, visible = false })

                      chat.references:add({
                        bufnr = item.buf,
                        id = id,
                        path = item.file,
                        source = '',
                      })
                    end)
                  end,
                },
                win = { input = { keys = { ['<CR>'] = { 'add_to_chat', mode = { 'i', 'n' } } } } },
                filter = { filter = function(item) return vim.bo[item.buf].buftype == 'terminal' end },
                main = { file = false },
              })
            end,
            description = 'Insert terminal output',
            opts = {
              provider = 'snacks',
            },
          },
        },
      },
    },
  },
}
