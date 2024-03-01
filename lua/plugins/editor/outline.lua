return {
  'hedyhli/outline.nvim',
  cmd = { 'Outline', 'OutlineOpen' },
  keys = {
    { '<leader>go', '<cmd>Outline<CR>', desc = 'Toggle outline' },
  },
  opts = {
    keymaps = {
      up_and_jump = '<C-p>',
      down_and_jump = '<C-n>',
    },
    outline_window = {
      -- Automatically scroll to the location in code when navigating outline window.
      auto_jump = false,
      focus_on_open = false,
    },
    outline_items = {
      -- Show extra details with the symbols (lsp dependent) as virtual next
      show_symbol_details = false,
      -- Whether to highlight the currently hovered symbol and all direct parents
      highlight_hovered_item = true,
      -- Autocmd events to automatically trigger these operations.
      auto_update_events = {
        -- Includes both setting of cursor and highlighting of hovered item.
        -- The above two options are respected.
        -- This can be triggered manually through `follow_cursor` lua API,
        -- :OutlineFollow command, or <C-g>.
        follow = { 'CursorMoved' },
        -- Re-request symbols from the provider.
        -- This can be triggered manually through `refresh_outline` lua API, or
        -- :OutlineRefresh command.
        items = { 'InsertLeave', 'WinEnter', 'BufEnter', 'BufWinEnter', 'TabEnter', 'BufWritePost' },
      },
    },
  },
}
