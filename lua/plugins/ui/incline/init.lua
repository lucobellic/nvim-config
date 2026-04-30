local separator_char = '-'
local unfocused = 'NonText'
local focused = 'Comment'

local icons = {
  ERROR = ' ',
  WARN = ' ',
  HINT = ' ',
  INFO = ' ',
}

local git_icons = {
  added = ' ',
  modified = ' ',
  removed = ' ',
}

-- Handlers are checked in order; first match wins
local handlers = {
  require('plugins.ui.incline.snacks-terminal'),
  require('plugins.ui.incline.overseer-output'),
  require('plugins.ui.incline.edgy'),
  require('plugins.ui.incline.codecompanion'),
}

local function get_diagnostic_label(props)
  local label = {}
  local severities = { 'ERROR', 'WARN', 'HINT', 'INFO' }

  for _, severity in ipairs(severities) do
    local icon = icons[severity]
    local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity] })
    if n > 0 then
      table.insert(label, { icon .. n .. ' ', group = props.focused and 'DiagnosticSign' .. severity or unfocused })
    end
  end
  return label
end

local function get_git_diff(props)
  local diff_icons = { removed = git_icons.removed, changed = git_icons.modified, added = git_icons.added }
  local highlight = { removed = 'GitSignsDelete', changed = 'GitSignsChange', added = 'GitSignsAdd' }
  local labels = {}
  local ok, signs = pcall(vim.api.nvim_buf_get_var, props.buf, 'gitsigns_status_dict')
  if ok then
    for name, icon in pairs(diff_icons) do
      if tonumber(signs[name]) and signs[name] > 0 then
        table.insert(labels, {
          icon .. signs[name] .. ' ',
          group = props.focused and highlight[name] or unfocused,
        })
      end
    end
  end
  return labels
end

local function get_search_count(props)
  if vim.v.hlsearch == 0 then
    return {}
  end

  if props.buf ~= vim.api.nvim_get_current_buf() then
    return {}
  end

  local ok, search = pcall(vim.fn.searchcount)
  if not ok or not search.total then
    return {}
  end

  local search_text = string.format('[%d/%d] ', search.current, math.min(search.total, search.maxcount))
  return { { search_text, group = props.focused and 'Identifier' or unfocused } }
end

return {
  'b0o/incline.nvim',
  event = { 'User LazyBufEnter' },
  keys = {
    {
      '<leader>uo',
      function()
        if require('incline').is_enabled() then
          vim.notify('Disabled Incline', vim.log.levels.WARN, { title = 'Incline' })
        else
          vim.notify('Enabled Incline', vim.log.levels.INFO, { title = 'Incline' })
        end
        require('incline').toggle()
      end,
      desc = 'Toggle incline',
    },
  },
  opts = {
    debounce_threshold = { rising = 50, falling = 50 },
    window = {
      margin = {
        vertical = { top = 0, bottom = 0 }, -- shift to overlap window borders
        horizontal = { left = 0, right = 0 }, -- shift for scrollbar
      },
      overlap = {
        borders = true,
        statusline = true,
        tabline = false,
        winbar = true,
      },
      zindex = 20,
    },
    hide = {
      cursorline = false,
    },
    ignore = {
      buftypes = {},
      filetypes = { 'neo-tree', 'dashboard', 'snacks_dashboard', 'neominimap' },
      unlisted_buffers = false,
    },
    render = function(props)
      for _, handler in ipairs(handlers) do
        if handler:match(props) then
          return handler:render(props)
        end
      end

      -- Default: file buffer with icon, diagnostics, git diff, search count
      local filename = vim.fn.fnamemodify(vim.fn.bufname(props.buf), ':t')
      local filetype_icon, filetype_color = require('nvim-web-devicons').get_icon_color(filename)
      local diagnostics = get_diagnostic_label(props)
      local diffs = get_git_diff(props)
      local search_count = get_search_count(props)

      local color = props.focused and focused or unfocused
      local icon = props.focused and { filetype_icon, guifg = filetype_color } or { filetype_icon, group = unfocused }

      local has_info = #diagnostics > 0 or #diffs > 0 or #search_count > 0
      local separator = (#diagnostics > 0 and (#diffs > 0 or #search_count > 0))
          and { separator_char .. ' ', group = color }
        or ''
      local search_separator = (#diffs > 0 and #search_count > 0) and { separator_char .. ' ', group = color } or ''
      local filename_separator = has_info and { ' ' .. separator_char .. ' ', group = color } or ''

      local filename_component = {
        icon,
        { filetype_icon and ' ' or '' },
        { ' ' .. filename .. ' ', group = props.focused and 'FloatTitle' or 'Title' },
        filename_separator,
      }

      if vim.bo[props.buf].buflisted then
        filename_component = {}
      end

      return {
        filename_component,
        { diagnostics },
        { separator },
        { diffs },
        { search_separator },
        { search_count },
      }
    end,
  },
  config = function(_, opts) require('incline').setup(opts) end,
}
