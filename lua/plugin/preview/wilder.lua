local wilder = require('wilder')
wilder.setup({ modes = { ':', '/', '?' } })

-- Disable Python remote plugin
wilder.set_option('use_python_remote_plugin', 0)

-- Fuzzy find
wilder.set_option('pipeline', {
  wilder.branch(
    {
      wilder.check(function(_, x) return x == '' end),
      wilder.history(),
    },
    wilder.cmdline_pipeline({
      -- 0 turns off fuzzy matching
      -- 1 turns on fuzzy matching
      -- 2 partial fuzzy matching (match does not have to begin with the same first letter)
      fuzzy = 2,
      fuzzy_filter = wilder.lua_fzy_filter(),
    }),
    wilder.vim_search_pipeline()
  )
})

local gradient = {
  '#f4468f', '#fd4a85', '#ff507a', '#ff566f', '#ff5e63',
  '#ff6658', '#ff704e', '#ff7a45', '#ff843d', '#ff9036',
  '#f89b31', '#efa72f', '#e6b32e', '#dcbe30', '#d2c934',
  '#c8d43a', '#bfde43', '#b6e84e', '#aff05b'
}

for i, fg in ipairs(gradient) do
  gradient[i] = wilder.make_hl('WilderGradient' .. i, 'Pmenu', { { a = 1 }, { a = 1 }, { foreground = fg } })
end

wilder.set_option('renderer', wilder.popupmenu_renderer(
  wilder.popupmenu_palette_theme({
    border = {
      '', '', '',
      ' ', ' ',
      ' ', ' ', ' ',
    },
    -- border = {
    --   '╭', '─', '╮',
    --   '│',      '│',
    --   '╰', '─', '╯',
    -- },
    max_width = '31%',
    margin = 6,              -- 5 stick to noice cmdline with 1 margin and without border
    min_height = 0,          -- set to the same as 'max_height' for a fixed height window
    prompt_position = 'top', -- 'top' or 'bottom' to set the location of the prompt
    reverse = 0,             -- set to 1 to reverse the order of the list, use in combination with 'prompt_position'
    pumblend = 20,
    -- empty_message = 'Test',
    highlights = {
      prompt = 'Dark',
      prompt_cursor = 'Dark',
      border = 'CursorLine',
      default = 'CursorLine',
      gradient = gradient, -- must be set
      -- selected_gradient key can be set to apply gradient highlighting for the selected candidate.
    },
    highlighter = wilder.highlighter_with_gradient({
      -- wilder.basic_highlighter(),
      wilder.lua_fzy_highlighter(),
    }),
    left = { ' ', wilder.popupmenu_devicons() },
    right = { ' ',
      wilder.popupmenu_scrollbar({
        thumb_char = '█',
      })
    },
  })
))
