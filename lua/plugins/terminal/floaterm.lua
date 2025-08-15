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

--- Function to override the floaterm#window#open function
--- @param bufnr number
--- @param config table floaterm configuration
--- @return number winid
local function open_popup(bufnr, config)
  local highlights = {
    'TelescopePromptTitle',
    'TelescopeResultsTitle',
    'TelescopePreviewTitle',
  }

  local function get_highlight(index)
    local term_index = tonumber(index:match('%d') or '1') - 1
    local highlight_index = (term_index % #highlights) + 1
    local highlight = highlights[highlight_index]
    return highlight
  end

  --- Get popup highlight string with title highlight based on index value
  --- Find the first digit as index from the provided string
  --- @param index string
  --- @return string
  local function get_window_highlight(index)
    return ('Normal:Normal,FloatBorder:FloatBorder,FloatTitle:%s'):format(get_highlight(index))
  end

  --- Extract title and index from floaterm title
  --- @param title string @Title provided by floaterm, expected format: "Title 1/2"
  --- @return {title:string, index:string, total:string}
  local function extract_title_and_index(title)
    local tokens = title.gmatch(title, '[^%s]+')
    local title_part = tokens() or ''
    local index_part = tokens() or ''
    local current, total = index_part:match('(%d+)/(%d+)')
    return { title = title_part, index = current or '1', total = total or '1' }
  end

  --- Generate terminal number sequence (1, 2, 3, etc.) up to total count
  --- @param total string @Total number of terminals
  --- @param current string @Current terminal index
  --- @return NuiLine
  local function generate_terminal_sequence(total, current)
    local NuiLine = require('nui.line')
    local NuiText = require('nui.text')
    local count = tonumber(total) or 1
    local current_num = tonumber(current) or 1
    local line = NuiLine()
    for i = 1, count do
      local highlight = (i == current_num) and get_highlight(current) or 'FloatBorder'
      line:append(NuiText(' ' .. tostring(i) .. ' ', highlight))
      if i < count then
        line:append(NuiText('─', 'FloatBorder'))
      end
    end
    return line
  end

  local parsed_title = extract_title_and_index(config.title)

  local Popup = require('nui.popup')

  local popup = Popup({
    position = '50%',
    bufnr = bufnr,
    size = {
      width = config.width,
      height = config.height,
    },
    enter = true,
    focusable = true,
    zindex = 100,
    relative = 'editor',
    border = {
      padding = {
        top = 0,
        bottom = 0,
        left = 0,
        right = 0,
      },
      style = vim.g.border.style,
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

  popup:mount()
  return popup.winid
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
    -- TODO: Start the buffer using opencode.lua instead of creating a new terminal
    { '<leader>to', '<cmd>FloatermToggleTool opencode<cr>', desc = 'OpenCode' },
    -- TODO: Start the buffer using cursor-agent.lua instead of creating a new terminal
    { '<leader>tc', '<cmd>FloatermToggleTool cursor-agent<cr>', desc = 'Cursor Agent' },
    { '<leader>ey', '<cmd>FloatermToggleTool yazi<cr>', desc = 'Yazi' },
    { '<F7>', '<cmd>FloatermToggle<cr>', mode = { 'n', 'i' }, desc = 'Floaterm Toggle' },
    { '<F7>', '<C-\\><C-n>:FloatermToggle<cr>', mode = 't', desc = 'Floaterm Toggle' },
    { '<F8>', '<cmd>FloatermToggleBuffer<cr>', mode = 'n', desc = 'Floaterm toggle buffer' },
    { '<F8>', '<C-\\><C-n>:FloatermToggleBuffer<cr>', mode = 't', desc = 'Floaterm toggle buffer' },
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
