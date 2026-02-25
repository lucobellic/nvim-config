if vim.g.neovide then
  local font_family = 'DMMono Nerd Font'
  local font_size = 12
  vim.g.guifont = font_family .. ':h' .. font_size
  vim.opt.linespace = 2
  vim.opt.columns = 1024

  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.2
  vim.g.neovide_scroll_animation_length = 0.2
  vim.g.neovide_cursor_animate_command_line = false
  vim.g.neovide_cursor_vfx_mode = 'pixiedust'
  vim.g.neovide_hide_mouse_when_typing = true

  vim.g.neovide_opacity = 0.95
  vim.g.neovide_normal_opacity = 0.55

  vim.g.neovide_floating_blur = true
  vim.g.neovide_floating_blur_amount_x = 5.0
  vim.g.neovide_floating_blur_amount_y = 5.0
  vim.g.neovide_floating_corner_radius = 0
  vim.g.neovide_floating_xray = true

  vim.g.neovide_padding_top = 2
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
  vim.g.terminal_color_9 = '#ff7a5d'

  -- green
  vim.g.terminal_color_2 = '#aad94c'
  vim.g.terminal_color_10 = '#e9fe83'

  -- yellow
  vim.g.terminal_color_3 = '#ffb454'
  vim.g.terminal_color_11 = '#ffcc66'

  -- blue
  vim.g.terminal_color_4 = '#39bae6'
  vim.g.terminal_color_12 = '#59c2ff'

  -- magenta
  vim.g.terminal_color_5 = '#d2a6ff'
  vim.g.terminal_color_13 = '#d2a6ff'

  -- cyan
  vim.g.terminal_color_6 = '#95e6cb'
  vim.g.terminal_color_14 = '#c7fffc'

  -- white
  vim.g.terminal_color_7 = '#bfbdb6'
  vim.g.terminal_color_15 = '#bfbdb6'

  -- Shadow
  vim.g.neovide_floating_z_height = 5 -- virtual height of floating window
  vim.g.neovide_light_angle_degrees = 0 -- angle from screen normal of the casting light
  vim.g.neovide_light_radius = 5 -- radius of the casting light

  -- fix border and winbar scrolling glitches
  vim.g.neovide_unlink_border_highlights = true
  vim.g.neovide_experimental_layer_grouping = true

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

  vim.keymap.set('n', '<c-end>', function()
    if vim.g.neovide_opacity ~= 1.0 and vim.g.neovide_normal_opacity ~= 1.0 then
      vim.g.previous_opacity = vim.g.neovide_opacity
      vim.g.previous_normal_opacity = vim.g.neovide_normal_opacity
      vim.g.neovide_opacity = 1.0
      vim.g.neovide_normal_opacity = 1.0
    else
      vim.g.neovide_opacity = vim.g.neovide_previous_opacity or 0.95
      vim.g.neovide_normal_opacity = vim.g.neovide_previous_normal_opacity or 0.55
    end
  end, { silent = true, repeatable = true, desc = 'Toggle opacity' })

  local function save() vim.cmd.write() end
  local function copy() vim.cmd([[normal! "+y]]) end
  local function paste() vim.api.nvim_paste(vim.fn.getreg('+'), true, -1) end

  vim.keymap.set({ 'n', 'i', 'v' }, '<C-S-s>', save, { desc = 'Save' })
  vim.keymap.set('v', '<C-S-c>', copy, { silent = true, desc = 'Copy' })
  vim.keymap.set({ 'n', 'i', 'v', 'c', 't' }, '<C-S-v>', paste, { silent = true, desc = 'Paste' })
end
