local separator_char = '│'

local function get_diagnostic_label(props)
  local icons = require('lazyvim.config').icons.diagnostics
  local label = {}

  for severity, icon in pairs(icons) do
    local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
    if n > 0 then
      table.insert(label, { icon .. n .. ' ', group = 'DiagnosticSign' .. severity })
    end
  end
  return label
end

local function get_git_diff(props)
  local git_icons = require('lazyvim.config').icons.git
  local icons = { removed = git_icons.removed, changed = git_icons.modified, added = git_icons.added }
  local highlight = { removed = 'GitSignsDelete', changed = 'GitSignsChange', added = 'GitSignsAdd' }
  local labels = {}
  local ok, signs = pcall(vim.api.nvim_buf_get_var, props.buf, 'gitsigns_status_dict')
  if ok then
    for name, icon in pairs(icons) do
      if tonumber(signs[name]) and signs[name] > 0 then
        table.insert(labels, {
          icon .. signs[name] .. ' ',
          group = highlight[name],
        })
      end
    end
  end
  return labels
end

local function get_toggleterm_id(props)
  local id = vim.fn.bufname(props.buf):sub(-1)
  return { { id, group = props.focused and 'Identifier' or 'FloatBorder' } }
end

local function is_toggleterm(bufnr) return vim.bo[bufnr].filetype == 'toggleterm' end

return {
  'b0o/incline.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>uo',
      function() require('incline').toggle() end,
      desc = 'Toggle incline',
    },
  },
  opts = {
    window = {
      zindex = 1,
      margin = {
        vertical = { top = vim.o.laststatus == 3 and 0 or 1, bottom = 0 }, -- shift to overlap window borders
        horizontal = { left = 0, right = 2 }, -- shift for scrollbar
      },
    },
    hide = {
      cursorline = true,
    },
    ignore = {
      buftypes = function(bufnr, buftype) return buftype ~= '' and not is_toggleterm(bufnr) end,
      unlisted_buffers = false,
    },
    render = function(props)
      if is_toggleterm(props.buf) then
        return get_toggleterm_id(props)
      end

      local diagnostics = get_diagnostic_label(props)
      local diffs = get_git_diff(props)
      local separator = (#diagnostics > 0 and #diffs > 0) and { separator_char .. ' ', group = 'NonText' } or ''
      local buffer = {
        { diagnostics },
        { separator },
        { diffs },
      }
      return buffer
    end,
  },
}
