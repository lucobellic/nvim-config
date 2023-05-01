require("bufferline").setup {
  options = {
    indicator = {
      icon = '▎',
      style = 'icon',
    },
    show_buffer_icons = true,        -- disable filetype icons for buffers
    show_buffer_close_icons = false,
    show_buffer_default_icon = true, -- whether or not an unrecognised filetype should show a default icon
    show_close_icon = false,
    show_tab_indicators = true,
    separator_style = "thin",
    buffer_close_icon = '',
    modified_icon = '',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
  },
  highlights = {
    buffer_selected = {
      bold = false,
      italic = false,
    },
    pick_selected = {
      bold = false,
      italic = false,
    },
    pick_visible = {
      bold = false,
      italic = false,
    },
    pick = {
      bold = false,
      italic = false,
    },
    modified = {
      fg = '#39bae6',
    },
    modified_visible = {
      fg = '#39bae6',
    },
    modified_selected = {
      fg = '#39bae6',
    },
  }
}

local function close_all_but_current_buffer()
  for _, e in ipairs(require("bufferline").get_elements().elements) do
    vim.schedule(function()
      if e.id == vim.api.nvim_get_current_buf() then
        return
      else
        vim.cmd("bd " .. e.id)
      end
    end)
  end
end

vim.api.nvim_create_user_command('BufferLineCloseAllButCurrent', close_all_but_current_buffer, {})
