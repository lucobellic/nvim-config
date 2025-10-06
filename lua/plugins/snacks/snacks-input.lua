---@module 'snacks.input'

return {
  'snacks.nvim',
  opts = {
    ---@type table<string, snacks.win.Config>
    styles = {
      above_cursor = {
        backdrop = false,
        position = 'float',
        border = vim.g.border.style,
        title_pos = 'left',
        height = 1,
        noautocmd = true,
        relative = 'cursor',
        row = -3,
        col = 0,
        wo = {
          cursorline = false,
        },
        bo = {
          filetype = 'snacks_input',
          buftype = 'prompt',
        },
        --- buffer local variables
        b = {
          completion = true, -- enable/disable blink completions in input
        },
        keys = {
          n_esc = { '<esc>', { 'cmp_close', 'cancel' }, mode = 'n', expr = true },
          i_esc = { '<esc>', { 'cmp_close', 'stopinsert' }, mode = 'i', expr = true },
          i_cr = { '<cr>', { 'cmp_accept', 'confirm' }, mode = 'i', expr = true },
          i_tab = { '<tab>', { 'cmp_select_next', 'cmp', 'fallback' }, mode = 'i', expr = true },
          i_ctrl_w = { '<c-w>', '<c-s-w>', mode = 'i', expr = true },
          i_up = { '<up>', { 'hist_up' }, mode = { 'i', 'n' } },
          i_down = { '<down>', { 'hist_down' }, mode = { 'i', 'n' } },
          q = 'cancel',
        },
      },
    },
    input = {
      enabled = true,
      win = {
        style = 'above_cursor',
      },
    },
  },
}
