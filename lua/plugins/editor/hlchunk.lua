return {
  'shellRaining/hlchunk.nvim',
  event = { 'UIEnter' },
  opts = {
    chunk = {
      enable = false, -- prefer mini-indent-scope for current scope highlight
      use_treesitter = false,
      notify = false, -- notify if some situation(like disable chunk mod double time)
      exclude_filetypes = {
        aerial = true,
        dashboard = true,
        sagaoutline = true,
      },
      support_filetypes = {
        '*',
      },
      chars = {
        horizontal_line = '─',
        vertical_line = '│',
        left_top = '╭',
        -- left_top = '┌',
        left_bottom = '╰',
        -- left_bottom = '└',
        right_arrow = '─',
      },
      -- style = { '#4d5566' },
      style = { '#ffcc66' }
    },

    indent = {
      enable = true,
      use_treesitter = false,
      chars = { '▏' },
      -- style = { '#4d5566' },
      style = { '#1a2632' },
    },

    line_num = { enable = false },
    blank = { enable = false },
  }
}
