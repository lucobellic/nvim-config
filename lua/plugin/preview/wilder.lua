local wilder = require('wilder')
wilder.setup({ modes = { ':', '/', '?' } })

-- Disable Python remote plugin
wilder.set_option('use_python_remote_plugin', 0)

-- Fuzzy find
wilder.set_option('pipeline', {
  wilder.branch(
    wilder.cmdline_pipeline({
      fuzzy = 1,
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
    -- border = {
    --   ' ', ' ', ' ',
    --   ' ', ' ', ' ',
    --   ' ', ' ', ' '
    -- },
    -- prompt_border = { '╭', '─', '╮' },
    -- 'single', 'double', 'rounded' or 'solid'
    border = 'rounded',
    max_height = '30%', -- max height of the palette
    max_width = '40%',
    margin = '2%',
    min_height = 0, -- set to the same as 'max_height' for a fixed height window
    prompt_position = 'top', -- 'top' or 'bottom' to set the location of the prompt
    reverse = 0, -- set to 1 to reverse the order of the list, use in combination with 'prompt_position'
    pumblend = 20,
    -- empty_message = 'Test',
    highlights = {
      prompt = 'Normal',
      prompt_cursor = 'Title',
      border = 'Structure',
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
