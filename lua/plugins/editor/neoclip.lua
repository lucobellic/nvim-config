local function snack_clip()
  local yanks = require('neoclip.storage').get().yanks

  --- @type snacks.picker.finder.Item[]
  local contents = vim
    .iter(yanks)
    :enumerate()
    :map(function(idx, item)
      local content = item.contents[1] or ''
      local text = #item.contents > 1 and content .. ' +' .. #item.contents - 1 .. '...' or content

      --- @type snacks.picker.finder.Item
      return {
        text = text,
        contents = item.contents,
        preview = {
          text = table.concat(item.contents, '\n'),
        },
        idx = idx,
      }
    end)
    :totable()

  local Snacks = require('snacks')
  Snacks.picker.pick({
    title = 'Yank History',
    items = contents,
    format = 'text',
    preview = 'preview',
    actions = {
      --- @param picker snacks.Picker
      --- @param item snacks.picker.Item
      confirm = function(picker, item)
        vim.fn.setreg('+', item.contents, 'l')
        picker:close()
      end,
    },
  })
end

return {
  'AckslD/nvim-neoclip.lua',
  event = 'BufEnter',
  dependencies = { 'kkharji/sqlite.lua' },
  keys = { { '<leader>sy', function() snack_clip() end, desc = 'Find yanks (neoclip)' } },
  opts = {
    enable_persistent_history = true,
    keys = {
      telescope = {
        i = {
          paste = '<cr>',
        },
      },
    },
  },
}
