-- Set barbar's options
require('barbar').setup {
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
    pinned = { button = '📎'},
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
}

--------------------------------------------------------------------------------
------------------------- Tabpage buffers management ---------------------------
--------------------------------------------------------------------------------
-- TODO: Handle buffer order when same buffer is present in multiple tabpages.

local state = require('barbar.state')

---On TabLeave, save the list of visible buffers and hide them if any.
---@package
local save_and_hide_tabpage_buffers = function()
  -- Save visible buffers
  vim.t.visible_buffers = state.get_buffer_list()

  -- Hide buffers
  for _, buffer in ipairs(vim.t.visible_buffers or {}) do
    if vim.api.nvim_buf_is_valid(buffer) then
      vim.api.nvim_buf_set_option(buffer, 'buflisted', false)
    end
  end
end


---On TabEnter, display previously saved visible buffer if any.
---@package
local load_tabpage_buffers = function()
  for _, buffer in ipairs(vim.t.visible_buffers or {}) do
    vim.api.nvim_buf_set_option(buffer, 'buflisted', true)
  end
end

---On TabClosed, clear the list of visible buffers.
---@package
local function clear_tabpage_buffers(tabpage_id)
  if tabpage_id and vim.api.nvim_tabpage_is_valid(tabpage_id) then
    vim.api.nvim_tabpage_del_var(tabpage_id, 'visible_buffers')
  end
end

vim.api.nvim_create_autocmd({ 'TabLeave' }, {
  pattern = { '*' },
  callback = function()
    vim.t.buffers = state.buffers
    save_and_hide_tabpage_buffers()
  end
})

vim.api.nvim_create_autocmd({ 'TabEnter' }, {
  pattern = { '*' },
  callback = function()
    load_tabpage_buffers()
    if vim.t.buffers then
      state.buffers = vim.t.buffers
    end
  end
})

vim.api.nvim_create_autocmd({ 'TabClosed' }, {
  pattern = { '*' },
  callback = function(ev)
    clear_tabpage_buffers(ev.id)
  end
})

