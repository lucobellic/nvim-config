---@type snacks.picker.Config
local overseer_template = {
  win = {
    input = {
      keys = {
        ['<c-cr>'] = {
          'overseer_queue_template',
          mode = { 'n', 'i' },
          desc = 'Queue selected template',
        },
      },
    },
  },
  actions = {
    overseer_queue_template = function(picker)
      local items = picker:selected({ fallback = true })
      if #items > 0 then
        local queue = require('overseer.util.queue')
        vim.iter(items):each(function(item) queue.schedule({ name = item.item.name }) end)
      end
      picker:close()
    end,
  },
}

return {
  'folke/snacks.nvim',
  opts = {
    picker = {
      sources = {
        select = {
          kinds = {
            overseer_template = overseer_template,
          },
        },
      },
    },
  },
}
