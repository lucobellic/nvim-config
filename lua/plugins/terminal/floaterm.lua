local function floaterm_toggle(params)
  local tool_name = params.args
  local tool_title = tool_name:gsub('^%l', string.upper)
  local bufnr = vim.api.nvim_call_function('floaterm#terminal#get_bufnr', { tool_name })
  if bufnr == -1 then
    local format =
      string.format('--height=0.9 --width=0.9 --title=%s\\ $1/$2 --name=%s %s', tool_title, tool_name, tool_name)
    vim.api.nvim_call_function('floaterm#run', { 'new', tool_name, { 'v', 0, 0, 0 }, format })
  else
    vim.api.nvim_call_function('floaterm#toggle', { 0, bufnr, '' })
  end
end

--- Function to override the floaterm#window#open function
---@param bufnr number
---@param config table floaterm configuration
---@return number winid
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
  ---@param index string
  ---@return string
  local function get_window_highlight(index)
    return ('Normal:Normal,FloatBorder:FloatBorder,FloatTitle:%s'):format(get_highlight(index))
  end

  --- Extract title and index from floaterm title
  ---@param title string @Title provided by floaterm, expected format: "Title 1/2"
  ---@return {title:string, index:string, total:string}
  local function extract_title_and_index(title)
    local tokens = title.gmatch(title, '[^%s]+')
    local title_part = tokens() or ''
    local index_part = tokens() or ''
    local current, total = index_part:match('(%d+)/(%d+)')
    return { title = title_part, index = current or '1', total = total or '1' }
  end

  --- Generate terminal number sequence (1, 2, 3, etc.) up to total count
  ---@param total string @Total number of terminals
  ---@param current string @Current terminal index
  ---@return NuiLine
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
  cmd = { 'FloatermToggle', 'FloatermNew', 'FloatermNext', 'FloatermPrev' },
  dependencies = { 'MunifTanjim/nui.nvim' },
  keys = {
    { '<leader>er', '<cmd>FloatermToggleTool ranger<cr>', desc = 'Ranger' },
    { '<leader>g;', '<cmd>FloatermToggleTool lazygit<cr>', desc = 'Lazygit' },
    { '<leader>ao', '<cmd>FloatermToggleTool opencode<cr>', desc = 'OpenCode' },
    { '<leader>ey', '<cmd>FloatermToggleTool yazi<cr>', desc = 'Yazi' },
    { '<F7>', '<cmd>FloatermToggle<cr>', mode = 'n', desc = 'Toggle Floaterm' },
    { '<F7>', '<C-\\><C-n>:FloatermToggle<cr>', mode = 't', desc = 'Toggle Floaterm' },
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
    vim.api.nvim_create_user_command('FloatermToggleTool', floaterm_toggle, { nargs = 1, count = 1 })
  end,
}
