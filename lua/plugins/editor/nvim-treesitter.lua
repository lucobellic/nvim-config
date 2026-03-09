local keys = function(textobjects)
  local move = require('nvim-treesitter-textobjects.move')

  local keymaps = vim
    .iter(textobjects)
    :map(function(key, object)
      local lower_key = key:lower()
      local upper_key = key:upper()

      -- '@function.outer' -> 'Function'
      local part = object:gsub('@', ''):gsub('%..*', '')
      part = part:sub(1, 1):upper() .. part:sub(2)

      local mode = { 'n', 'x', 'o' }
      local prev_start = function() move.goto_previous_start(object, 'textobjects') end
      local next_start = function() move.goto_next_start(object, 'textobjects') end
      local prev_end = function() move.goto_previous_end(object, 'textobjects') end
      local next_end = function() move.goto_next_start(object, 'textobjects') end
      local repeatable_goto_start = { [','] = prev_start, [';'] = next_start }
      local repeatable_goto_end = { [','] = prev_end, [';'] = next_end }

      return {
        {
          mode = mode,
          '[' .. lower_key,
          prev_start,
          repeatable = repeatable_goto_start,
          desc = 'Prev ' .. part .. ' Start',
        },
        {
          mode = mode,
          ']' .. lower_key,
          next_start,
          repeatable = repeatable_goto_start,
          desc = 'Next ' .. part .. ' Start',
        },
        {
          mode = mode,
          '[' .. upper_key,
          prev_end,
          repeatable = repeatable_goto_end,
          desc = 'Prev ' .. part .. ' End',
        },
        {
          mode = mode,
          ']' .. upper_key,
          next_end,
          repeatable = repeatable_goto_end,
          desc = 'Next ' .. part .. ' End',
        },
      }
    end)
    :totable()

  return vim.iter(keymaps):flatten():totable()
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = function() return { 'User LazyBufEnter' } end,
    opts = {},
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = function() return { 'User LazyBufEnter' } end,
    keys = keys({
      f = '@function.outer',
      c = '@class.outer',
      a = '@parameter.inner',
      m = '@method.outer',
    }),
    opts = {},
    config = function(_, opts) require('nvim-treesitter-textobjects').setup({ opts }) end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = function() return { 'User LazyBufEnter' } end,
    keys = {
      {
        '<leader>uk',
        function() require('treesitter-context').toggle() end,
        desc = 'Toggle Treesitter Context',
      },
    },
    opts = {
      line_numbers = true,
      max_lines = 5,
      min_window_height = 40,
      mode = 'topline',
      multiwindow = false,
      separator = (vim.g.winborder == 'none' or vim.g.winborder == 'solid') and ' ' or '─',
      trim_scope = 'inner',
      zindex = 20,
    },
  },
}
