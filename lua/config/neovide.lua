if vim.g.neovide then
  local font_family = 'DMMono Nerd Font'
  local font_size = 10
  vim.g.guifont = font_family .. ':h' .. font_size
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.2
  vim.g.neovide_scroll_animation_length = 0.2
  vim.g.neovide_hide_mouse_when_typing = true

  vim.g.neovide_transparency = 0.75
  vim.g.neovide_opacity = 0.75
  vim.g.neovide_text_background_opacity = 1.0
  vim.g.neovide_normal_opacity = 0.75

  vim.g.neovide_floating_blur = false
  vim.g.neovide_floating_blur_amount_x = 5.0
  vim.g.neovide_floating_blur_amount_y = 5.0
  vim.g.neovide_floating_corner_radius  = 0.5

  vim.g.neovide_padding_top = 5
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0

  -- Disable mini.animate with neovide
  vim.g.minianimate_disable = true

  vim.g.neovide_remember_window_size = true
  vim.g.neovide_fullscreen = false
  function _G.toggle_full_screen() vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen end

  -- Colors

  -- black
  vim.g.terminal_color_0 = '#0b0e14'
  vim.g.terminal_color_8 = '#0b0e14'

  -- red
  vim.g.terminal_color_1 = '#f26d78'
  vim.g.terminal_color_9 = '#f26d78'

  -- green
  vim.g.terminal_color_2 = '#aad94c'
  vim.g.terminal_color_10 = '#aad94c'

  -- yellow
  vim.g.terminal_color_3 = '#ffb454'
  vim.g.terminal_color_11 = '#ffb454'

  -- blue
  vim.g.terminal_color_4 = '#39bae6'
  vim.g.terminal_color_12 = '#39bae6'

  -- magenta
  vim.g.terminal_color_5 = '#d2a6ff'
  vim.g.terminal_color_13 = '#d2a6ff'

  -- cyan
  vim.g.terminal_color_6 = '#73b8ff'
  vim.g.terminal_color_14 = '#73b8ff'

  -- white
  vim.g.terminal_color_7 = '#bfbdb6'
  vim.g.terminal_color_15 = '#bfbdb6'

  -- Shadow
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10 -- virtual height of floating window
  vim.g.neovide_light_angle_degrees = 45 -- angle from screen normal of the casting light
  vim.g.neovide_light_radius = 5 -- radius of the casting light

  -- fix border and winbar scrolling glitches
  vim.g.neovide_unlink_border_highlights = true

  ---@param delta number
  local function change_font(delta)
    font_size = font_size + delta
    vim.o.guifont = font_family .. ':h' .. font_size
  end

  vim.keymap.set({ 'n' }, '<C-+>', function() change_font(1) end, {
    noremap = true,
    silent = true,
    repeatable = true,
    desc = 'Increase font size',
  })
  vim.keymap.set({ 'n' }, '<C-->', function() change_font(-1) end, {
    noremap = true,
    silent = true,
    repeatable = true,
    desc = 'Decrease font size',
  })

  vim.keymap.set('n', '<S-F11>', '<cmd>lua toggle_full_screen()<cr>', { silent = true })
  vim.keymap.set({ 'n', 'v' }, '<C-S-V>', '"+P') -- Paste normal mode
  vim.keymap.set('v', '<C-S-V>', '"+P') -- Paste visual mode
  vim.keymap.set('c', '<C-S-V>', '<C-R>+') -- Paste command mode
  vim.keymap.set('i', '<C-S-V>', '<ESC>l"+Pli') -- Paste insert mode

  -- Allow clipboard copy paste in neovim
  vim.keymap.set('', '<C-S-V>', '+p<CR>', { noremap = true, silent = true })
  vim.keymap.set({ '!', 't', 'v' }, '<C-S-V>', '<C-R>+', { noremap = true, silent = true })
end
