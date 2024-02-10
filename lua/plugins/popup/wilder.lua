return {
  'lucobellic/wilder.nvim',
  dependencies = { 'romgrk/fzy-lua-native' },
  event = 'VeryLazy',
  branch = 'personal',
  config = function()
    local wilder = require('wilder')
    wilder.setup({ modes = { ':', '/', '?' } })

    -- Disable Python remote plugin
    wilder.set_option('use_python_remote_plugin', 0)

    -- Fuzzy find
    wilder.set_option('pipeline', {
      wilder.branch(
        {
          wilder.check(function(ctx, x)
            return x == '' and vim.fn.getcmdtype() == ':'
          end),
          wilder.history(),
        },
        wilder.cmdline_pipeline({
          -- 0 turns off fuzzy matching
          -- 1 turns on fuzzy matching
          -- 2 partial fuzzy matching (match does not have to begin with the same first letter)
          fuzzy = 2,
          fuzzy_filter = wilder.lua_fzy_filter(),
        }),
        wilder.search_pipeline()
      ),
    })

    local gradient = {
      '#f4468f',
      '#fd4a85',
      '#ff507a',
      '#ff566f',
      '#ff5e63',
      '#ff6658',
      '#ff704e',
      '#ff7a45',
      '#ff843d',
      '#ff9036',
      '#f89b31',
      '#efa72f',
      '#e6b32e',
      '#dcbe30',
      '#d2c934',
      '#c8d43a',
      '#bfde43',
      '#b6e84e',
      '#aff05b',
    }

    for i, fg in ipairs(gradient) do
      gradient[i] = wilder.make_hl('WilderGradient' .. i, 'Pmenu', { { a = 1 }, { a = 1 }, { foreground = fg } })
    end

    if not vim.g.started_by_firenvim then
      wilder.set_option(
        'renderer',
        wilder.popupmenu_renderer(wilder.popupmenu_palette_theme({
          -- border = {
          --   ' ', ' ', ' ',
          --   ' ',      ' ',
          --   ' ', ' ', ' ',
          -- },
          border = {
            '╭',
            '─',
            '╮',
            '│',
            '│',
            '╰',
            '─',
            '╯',
          },
          max_width = '30%',
          margin = 6, -- 5 stick to noice cmdline with 1 margin and without border
          min_height = 0, -- set to the same as 'max_height' for a fixed height window
          max_height = 10,
          prompt_position = 'top', -- 'top' or 'bottom' to set the location of the prompt
          reverse = 0, -- set to 1 to reverse the order of the list, use in combination with 'prompt_position'
          pumblend = vim.o.pumblend,
          -- empty_message = 'Test',
          highlights = {
            default = 'NormalFloat',
            border = 'FloatBorder',
            gradient = gradient, -- must be set
            -- selected_gradient key can be set to apply gradient highlighting for the selected candidate.
          },
          highlighter = wilder.highlighter_with_gradient({
            -- wilder.basic_highlighter(),
            wilder.lua_fzy_highlighter(),
          }),
          left = { ' ', wilder.popupmenu_devicons() },
          right = {
            ' ',
            wilder.popupmenu_scrollbar({
              thumb_char = ' ',
              thumb_hl = 'Visual',
              scrollbar_char = ' ',
              scrollbar_hl = 'NONE',
            }),
          },
        }))
      )
    end
  end,
}
