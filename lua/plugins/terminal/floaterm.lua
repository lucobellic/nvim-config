--- Toggle a floaterm window for a specific tool
--- Creates a new terminal if it doesn't exist, otherwise toggles existing one
--- @param params {args: string} Command parameters containing the tool name
local function floaterm_toggle_tool(params)
  local tool_name = params.args
  local tool_title = tool_name:gsub('^%l', string.upper)
  local bufnr = vim.api.nvim_call_function('floaterm#terminal#get_bufnr', { tool_name })
  if bufnr == -1 then
    -- if tool_name == 'opencode' then
    --   require('util.opencode').open_code()
    -- end

    local format =
      string.format('--height=0.9 --width=0.9 --title=%s\\ $1/$2 --name=%s %s', tool_title, tool_name, tool_name)
    vim.api.nvim_call_function('floaterm#run', { 'new', tool_name, { 'v', 0, 0, 0 }, format })
  else
    vim.api.nvim_call_function('floaterm#toggle', { 0, bufnr, '' })
  end
end

--- Reset all floaterm keymaps to default
local function floaterm_reset_keymaps(bufnr)
  -- Clear all custom keymaps
  pcall(vim.keymap.del, 't', '<c-j>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<c-k>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<C-down>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<C-down>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<C-up>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<C-up>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', 'gf', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<C-q>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<C-q>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<esc>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<c-esc>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<c-bs>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', 'q', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<esc>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<C-l>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<S-right>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<C-l>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<S-right>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<C-h>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<S-left>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<C-h>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<S-left>', { buffer = bufnr })
  pcall(vim.keymap.del, 'n', '<C-t>', { buffer = bufnr })
  pcall(vim.keymap.del, 't', '<C-t>', { buffer = bufnr })
end

--- Send a buffer from floaterm that was moved from other window back to a new window in the current tab
--- @param floaterm_window number The window ID of the floating terminal
--- @param bufnr number The buffer number to be sent back to a new window
local function floaterm_send_to_window(floaterm_window, bufnr)
  -- Skip floating window that do not have previous filetype set
  local has_prev_filetype = pcall(vim.api.nvim_buf_get_var, bufnr, 'floaterm_prev_filetype')
  if not has_prev_filetype then
    return
  end

  -- Close the floating window displaying this buffer
  vim.api.nvim_win_close(floaterm_window, true)

  -- Remove the node from this buffer but do not kill the job
  vim.api.nvim_call_function('floaterm#buflist#remove', { bufnr, false })

  -- Restore original filetype if we saved it previously
  local previous_filetype = vim.api.nvim_buf_get_var(bufnr, 'floaterm_prev_filetype')
  vim.api.nvim_set_option_value('filetype', previous_filetype, { buf = bufnr })
  vim.api.nvim_buf_del_var(bufnr, 'floaterm_prev_filetype')

  -- Reset previously defined keymaps from ftplugin
  floaterm_reset_keymaps(bufnr)

  -- Open buffer in a new window in the currently active tab
  vim.cmd('split')
  vim.api.nvim_set_current_buf(bufnr)
end

local function floaterm_open_existing_buffer(bufnr)
  -- Add the buffer to the floaterm list if it is not already present
  local is_buffer_in_floaterm = vim.list_contains(vim.api.nvim_call_function('floaterm#buflist#gather', {}), bufnr)
  if not is_buffer_in_floaterm then
    vim.api.nvim_call_function('floaterm#buflist#add', { bufnr })
    -- Save and set filetype for floaterm
    local original_filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
    vim.api.nvim_buf_set_var(bufnr, 'floaterm_prev_filetype', original_filetype)
    vim.api.nvim_set_option_value('filetype', original_filetype .. '.floaterm', { buf = bufnr })
  end

  local title = vim.api.nvim_buf_get_name(bufnr):match('([^:]+)$') or vim.api.nvim_buf_get_name(bufnr)
  title = title .. ' $1/$2'
  vim.api.nvim_call_function(
    'floaterm#window#open',
    { bufnr, vim.api.nvim_call_function('floaterm#config#parse', { bufnr, { title = title } }) }
  )
end

--- Toggle a floaterm for an existing terminal buffer.
--- When opening, close other windows that display this buffer.
--- If the buffer does not exist or is not a terminal, do nothing.
---@param opts? {bufnr?: integer, close_other_wins?: boolean}
local function floaterm_toggle_terminal_buffer(opts)
  opts = opts or {}
  local bufnr = tonumber(opts.bufnr) or vim.api.nvim_get_current_buf()
  local close_other_wins = opts.close_other_wins == nil and false or opts.close_other_wins

  if not vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype ~= 'terminal' then
    return
  end

  local wins_containing_buf = vim
    .iter(vim.api.nvim_list_wins())
    :filter(function(win) return vim.api.nvim_win_get_buf(win) == bufnr end)
    :totable()

  local floaterm_window = vim
    .iter(wins_containing_buf)
    :filter(function(win)
      local cfg = vim.api.nvim_win_get_config(win)
      return cfg and cfg.relative ~= ''
    end)
    :next()

  if floaterm_window then
    floaterm_send_to_window(floaterm_window, bufnr)
    return
  end

  -- Close other windows that currently show this buffer
  if close_other_wins then
    vim
      .iter(wins_containing_buf)
      :filter(function(win) return win ~= floaterm_window end)
      :each(function(win) pcall(vim.api.nvim_win_close, win, true) end)
  end

  floaterm_open_existing_buffer(bufnr)
end

--- Store active layout and popups for reuse
--- @type NuiLayout|nil
local active_layout = nil

--- Helper functions for highlights and title parsing
local highlights = {
  'TelescopePromptTitle',
  'TelescopeResultsTitle',
  'TelescopePreviewTitle',
}

local function get_highlight(index)
  local term_index = tonumber(index:match('%d') or '1') - 1
  local highlight_index = (term_index % #highlights) + 1
  return highlights[highlight_index]
end

--- Get popup highlight string with title highlight based on index value
--- @param index string
--- @return string
local function get_window_highlight(index) return ('FloatTitle:%s'):format(get_highlight(index)) end

--- Extract title and index from floaterm title
--- @param title string Title provided by floaterm, expected format: "Title 1/2"
--- @return {title:string, index:string, total:string}
local function extract_title_and_index(title)
  local tokens = title.gmatch(title, '[^%s]+')
  local title_part = tokens() or ''
  local index_part = tokens() or ''
  local current, total = index_part:match('(%d+)/(%d+)')
  return { title = title_part, index = current or '1', total = total or '1' }
end

--- Generate terminal number sequence (1, 2, 3, etc.) up to total count
--- @param total string Total number of terminals
--- @param current string Current terminal index
--- @return NuiLine
local function generate_terminal_sequence(total, current)
  local NuiLine = require('nui.line')
  local NuiText = require('nui.text')
  local count = tonumber(total) or 1
  local current_num = tonumber(current) or 1
  local line = NuiLine()
  if vim.g.winborder == 'solid' then
    for i = 1, count do
      local highlight = (i == current_num) and get_highlight(current) or 'Comment'
      line:append(NuiText(' ' .. tostring(i) .. ' ', highlight))
    end
  else
    for i = 1, count do
      local highlight = (i == current_num) and get_highlight(current) or 'FloatBorder'
      line:append(NuiText(' ' .. tostring(i) .. ' ', highlight))
      if i < count then
        line:append(NuiText('─', 'FloatBorder'))
      end
    end
  end
  return line
end

--- Get all floaterm buffers with their titles and indices
--- @return table List of {bufnr: number, title: string, index: number}
local function get_all_floaterms()
  local floaterms = {}
  local buffers = vim.api.nvim_call_function('floaterm#buflist#gather', {})

  for index, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      -- Get the terminal name using floaterm#config#get
      local name = vim.api.nvim_call_function('floaterm#config#get', { buf, 'name', '' })

      -- Use the buffer name if no floaterm name is set
      if name == '' then
        name = vim.api.nvim_buf_get_name(buf)
        -- Extract just the terminal command/title from the buffer name if possible
        name = name:match('[^:]+$') or 'Terminal'
      end

      table.insert(floaterms, {
        bufnr = buf,
        title = name:gsub('^%l', string.upper), -- Capitalize first letter
        index = index,
      })
    end
  end

  return floaterms
end

local function get_index_icon(index)
  local icons = { '󰎦', '󰎩', '󰎬', '󰎮', '󰎰', '󰎵', '󰎸', '󰎻', '󰎾', '󰽾' }
  local idx = tonumber(index) or 1
  return icons[((idx - 1) % #icons) + 1]
end

--- Create menu with all floaterms
--- @param current_bufnr number The currently active terminal buffer
--- @param style string Border style for the menu
--- @return NuiMenu
local function create_floaterm_menu(current_bufnr, style)
  local Menu = require('nui.menu')
  local NuiText = require('nui.text')
  local NuiLine = require('nui.line')

  local floaterms = get_all_floaterms()

  local menu_items = {}
  for _, term in ipairs(floaterms) do
    local line = NuiLine()
    local highlight = (term.bufnr == current_bufnr) and 'Special' or 'Comment'
    line:append(NuiText(string.format('%s %s ', get_index_icon(term.index), term.title), highlight))
    table.insert(
      menu_items,
      Menu.item(line, {
        bufnr = term.bufnr,
        index = term.index,
      })
    )
  end

  local menu = Menu({
    enter = false,
    focusable = false,
    border = { style = style },
    win_options = {
      winblend = vim.o.winblend,
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
      cursorline = false,
    },
  }, {
    lines = menu_items,
  })

  return menu
end

--- Function to override the floaterm#window#open function
--- @param bufnr number
--- @param config table floaterm configuration
--- @return number winid
local function open_popup(bufnr, config)
  local parsed_title = extract_title_and_index(config.title)

  -- Create new layout with new buffer
  local Popup = require('nui.popup')
  local Layout = require('nui.layout')

  local style = vim.g.winborder == 'none' and 'single' or vim.g.winborder
  local zindex = 100

  -- Create terminal popup with the current buffer
  local terminal_popup = Popup({
    bufnr = bufnr,
    enter = true,
    focusable = true,
    zindex = zindex,
    border = {
      style = style,
      text = {
        top = ' ' .. parsed_title.title .. ' ',
        top_align = 'center',
        bottom = generate_terminal_sequence(parsed_title.total, parsed_title.index),
        bottom_align = 'center',
      },
    },
    buf_options = {
      modifiable = true,
      readonly = false,
    },
    win_options = {
      winblend = vim.o.winblend,
      winhighlight = get_window_highlight(parsed_title.index),
    },
  })

  -- Create layout with menu and terminal
  local previous_layout = active_layout
  active_layout = Layout(
    {
      position = 0.5,
      relative = 'editor',
      size = {
        width = config.width,
        height = config.height,
      },
    },
    Layout.Box({
      -- Layout.Box(create_floaterm_menu(bufnr, style), { size = { width = 15 } }),
      Layout.Box(terminal_popup, { size = '100%' }),
    }, { dir = 'row' })
  )

  terminal_popup:on('BufLeave', function() active_layout:unmount() end, { once = true })

  active_layout:mount()
  if previous_layout then
    previous_layout:unmount()
    previous_layout = nil
  end

  return terminal_popup.winid
end

local function pick_term()
  Snacks.picker.buffers({
    title = 'Terminals',
    hidden = true,
    sort_lastused = true,
    source = 'terminals',
    layout = { preset = 'telescope_vertical' },
    filter = {
      filter = function(item, filter)
        return item.buf and vim.api.nvim_get_option_value('buftype', { buf = item.buf }) == 'terminal' or false
      end,
    },
    confirm = function(picker)
      local selected = picker:selected({ fallback = true })[1]
      picker:close()
      if selected then
        local filetype = vim.api.nvim_get_option_value('filetype', { buf = selected.buf })
        if filetype:match('floaterm') then
          vim.schedule(function() floaterm_open_existing_buffer(selected.buf) end)
        else
          vim.api.nvim_set_current_buf(selected.buf)
        end
      end
    end,
  })
end

return {
  'lucobellic/vim-floaterm',
  branch = 'personal',
  cmd = {
    'FloatermToggle',
    'FloatermToggleTool',
    'FloatermToggleBuffer',
    'FloatermNew',
    'FloatermNext',
    'FloatermPrev',
  },
  dependencies = { 'MunifTanjim/nui.nvim' },
  keys = {
    { '<leader>er', '<cmd>FloatermToggleTool ranger<cr>', desc = 'Ranger' },
    { '<leader>g;', '<cmd>FloatermToggleTool lazygit<cr>', desc = 'Lazygit' },
    { '<leader>ey', '<cmd>FloatermToggleTool yazi<cr>', desc = 'Yazi' },
    { '<leader>ed', '<cmd>FloatermToggleTool lazydash<cr>', desc = 'Lazydash' },
    { '<F7>', '<cmd>FloatermToggle<cr>', mode = { 'n', 'i' }, desc = 'Floaterm Toggle' },
    { '<F7>', '<C-\\><C-n>:FloatermToggle<cr>', mode = 't', desc = 'Floaterm Toggle' },
    { '<F8>', '<cmd>FloatermToggleBuffer<cr>', mode = 'n', desc = 'Floaterm toggle buffer' },
    { '<F8>', '<C-\\><C-n>:FloatermToggleBuffer<cr>', mode = 't', desc = 'Floaterm toggle buffer' },
    { '<leader>ft', pick_term, desc = 'Find terminals' },
  },
  init = function()
    vim.g.floaterm_shell = vim.o.shell
    vim.g.floaterm_autoclose = 1 -- Close only if the job exits normally
    vim.g.floaterm_autohide = 2
    vim.g.floaterm_borderchars = vim.g.border.enabled and '─│─│╭╮╯╰' or ' '
    vim.g.floaterm_autoinsert = true
    vim.g.floaterm_titleposition = 'center'
    vim.g.floaterm_title = 'Terminal $1/$2'
    vim.g.floaterm_openoverride = open_popup
  end,
  config = function()
    vim.api.nvim_create_user_command('FloatermToggleTool', floaterm_toggle_tool, { nargs = 1, count = 1 })
    vim.api.nvim_create_user_command(
      'FloatermToggleBuffer',
      function() floaterm_toggle_terminal_buffer({ close_other_wins = true }) end,
      { desc = 'Floaterm toggle buffer' }
    )
  end,
}
