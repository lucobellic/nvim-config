return {
  'romgrk/barbar.nvim',
  event = 'User BufEnterExceptDashboard',
  dependencies = { 'folke/persistence.nvim' },
  keys = {
    { '<C-h>',      ':BufferPrevious<cr>',         desc = 'Buffer Previous' },
    { '<C-l>',      ':BufferNext<cr>',             desc = 'Buffer Next' },
    { '<A-h>',      ':BufferMovePrevious<cr>',     desc = 'Buffer Move Previous' },
    { '<A-l>',      ':BufferMoveNext<cr>',         desc = 'Buffer Move Next' },
    { '<A-p>',      ':BufferPin<cr>',              desc = 'Buffer Pin' },
    { '<C-1>',      ':BufferGoto 1<cr>',           desc = 'Buffer 1' },
    { '<C-2>',      ':BufferGoto 2<cr>',           desc = 'Buffer 2' },
    { '<C-3>',      ':BufferGoto 3<cr>',           desc = 'Buffer 3' },
    { '<C-4>',      ':BufferGoto 4<cr>',           desc = 'Buffer 4' },
    { '<C-5>',      ':BufferGoto 5<cr>',           desc = 'Buffer 5' },
    { '<C-6>',      ':BufferGoto 6<cr>',           desc = 'Buffer 6' },
    { '<C-7>',      ':BufferGoto 7<cr>',           desc = 'Buffer 7' },
    { '<C-8>',      ':BufferGoto 8<cr>',           desc = 'Buffer 8' },
    { '<C-9>',      ':BufferGoto 9<cr>',           desc = 'Buffer 9' },
    { '<C-0>',      ':BufferLast<cr>',             desc = 'Buffer Last' },
    { '<C-q>',      ':BufferClose<cr>',            desc = 'Buffer Close' },
    { '<C-/>',      ':BufferPick<cr>',             desc = 'Buffer Pick' },
    { '<leader>bd', ':BufferClose<cr>',            desc = 'Buffer Close' },
    { '<leader>bf', ':BufferOrderByDirectory<cr>', desc = 'Buffer Order By Directory' },
    { '<leader>bl', ':BufferOrderByLanguage<cr>',  desc = 'Buffer Order By Language' },
    { '<leader>bp', ':BufferPin<cr>',              desc = 'Buffer Order By Language' },
  },
  opts = {
    -- Enable/disable animations
    animation = true,

    -- Enable/disable auto-hiding the tab bar when there is a single buffer
    auto_hide = false,

    -- Enable/disable current/total tabpages indicator (top right corner)
    tabpages = true,

    -- Enables/disable clickable tabs
    --  - left-click: go to buffer
    --  - middle-click: delete buffer
    clickable = false,

    -- Excludes buffers from the tabline
    exclude_ft = { 'javascript', 'dashboard', 'neo-tree' },
    -- exclude_name = { 'package.json' },

    -- A buffer to this direction will be focused (if it exists) when closing the current buffer.
    -- Valid options are 'left' (the default) and 'right'
    focus_on_close = 'left',

    -- Hide inactive buffers and file extensions.
    -- Other options are `alternate`, `current`, and `visible`, `inactive`.
    hide = { extensions = true },

    -- Disable highlighting alternate buffers
    highlight_alternate = false,

    -- Disable highlighting file icons in inactive buffers
    highlight_inactive_file_icons = false,

    -- Enable highlighting visible buffers
    highlight_visible = true,

    icons = {
      -- Configure the base icons on the bufferline.
      buffer_index = false,
      buffer_number = false,
      button = '',
      -- Enables / disables diagnostic symbols
      diagnostics = {
        [vim.diagnostic.severity.ERROR] = { enabled = false, icon = '💀' },
        [vim.diagnostic.severity.WARN] = { enabled = false },
        [vim.diagnostic.severity.INFO] = { enabled = false },
        [vim.diagnostic.severity.HINT] = { enabled = false },
      },
      filetype = {
        -- Sets the icon's highlight group.
        -- If false, will use nvim-web-devicons colors
        custom_colors = false,
        -- Requires `nvim-web-devicons` if `true`
        enabled = true,
      },
      separator = { left = '▎', right = ' ' },
      -- Configure the icons on the bufferline when modified or pinned.
      -- Supports all the base icon options.
      modified = { button = '' },
      pinned = { button = '📎' },
      inactive = { separator = { left = ' ', right = ' ' } },
    },

    -- If true, new buffers will be inserted at the start/end of the list.
    -- Default is to insert after current buffer.
    insert_at_end = false,
    insert_at_start = false,

    -- Sets the maximum padding width with which to surround each tab
    maximum_padding = 1,

    -- Sets the minimum padding width with which to surround each tab
    minimum_padding = 1,

    -- Sets the maximum buffer name length.
    maximum_length = 30,

    -- If set, the letters for each buffer in buffer-pick mode will be
    -- assigned based on their name. Otherwise or in case all letters are
    -- already assigned, the behavior is to assign letters in order of
    -- usability (see order below)
    semantic_letters = false,

    -- New buffer letters are assigned in this order. This order is
    -- optimal for the qwerty keyboard layout but might need adjustement
    -- for other layouts.
    letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',

    -- Sets the name of unnamed buffers. By default format is "[Buffer X]"
    -- where X is the buffer number. But only a static string is accepted here.
    no_name_title = nil,

    -- Set the filetypes which barbar will offset itself for
    sidebar_filetypes = {
      NvimTree = true,
      ['neo-tree'] = { event = 'BufWipeout' },
    },
  }
}
