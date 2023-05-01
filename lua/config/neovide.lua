if vim.g.neovide then
  vim.cmd [[ set guifont=DMMono\ Nerd\ Font\ Mono:h11 ]]
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_cursor_trail_size = 0.2
  vim.g.neovide_scroll_animation_length = 0

  vim.g.neovide_remember_window_size = true
  vim.g.neovide_fullscreen = false
  function _G.toggle_full_screen()
    vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
  end

  vim.api.nvim_set_keymap('n', '<F11>', ':lua toggle_full_screen()<cr>', { silent = true })
end

