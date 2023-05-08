local separator = '▏'

local function get_diagnostic_label(props)
  local icons = { error = '', warn = '', info = '', hint = '', }
  local label = {}

  for severity, icon in pairs(icons) do
    local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
    if n > 0 then
      table.insert(label, { icon .. ' ' .. n .. ' ', group = 'DiagnosticSign' .. severity })
    end
  end
  if #label > 0 then
    table.insert(label, { separator, group = 'NonText' })
  end
  return label
end

local function get_git_diff(props)
  local icons = { removed = "", changed = "", added = "" }
  local hightligh = { removed = 'GitSignsDelete', changed = "GitSignsChange", added = 'GitSignsAdd' }
  local labels = {}
  local signs = vim.api.nvim_buf_get_var(props.buf, "gitsigns_status_dict")
  for name, icon in pairs(icons) do
    if tonumber(signs[name]) and signs[name] > 0 then
      table.insert(labels, {
        icon .. " " .. signs[name] .. " ",
        group = hightligh[name]
      })
    end
  end
  if #labels > 0 then
    table.insert(labels, { separator, group = 'NonText' })
  end
  return labels
end

require('incline').setup({
  debounce_threshold = {
    falling = 500,
    rising = 200
  },
  render = function(props)
    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
    local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
    local modified = vim.api.nvim_buf_get_option(props.buf, "modified") and "bold,italic" or "bold"

    local buffer = {
      { get_diagnostic_label(props) },
      { get_git_diff(props) },
      { ft_icon,                    guifg = ft_color }, { " " },
      { filename, gui = modified },
    }
    return buffer
  end
})
