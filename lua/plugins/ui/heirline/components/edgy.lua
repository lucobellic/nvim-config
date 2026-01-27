local mode_helpers = require('plugins.ui.heirline.components.mode')
local colors = require('plugins.ui.heirline.colors').colors

local hl_names = {
  'EdgyGroupActiveBottom',
  'EdgyGroupInactiveBottom',
  'EdgyGroupPickActiveBottom',
  'EdgyGroupPickInactiveBottom',
  'EdgyGroupSeparatorActiveBottom',
  'EdgyGroupSeparatorInactiveBottom',
}

local function update_highlights()
  local mode = vim.fn.mode()
  mode = mode and mode:sub(1, 1) or 'n'
  if mode == 'n' then
    vim.iter(hl_names):each(function(name) vim.api.nvim_set_hl(0, name, { link = name:gsub('Bottom', '') }) end)
  else
    local hl = mode_helpers.primary_highlight()
    if hl and hl.bg then
      vim.iter(hl_names):each(function(name) vim.api.nvim_set_hl(0, name, { bg = hl.bg, fg = colors.black }) end)
    end
  end
end

local LeftAlignment = {
  init = function(self)
    local mid_screen = math.floor(vim.api.nvim_get_option_value('columns', {}) / 2)
    local mid_section = table.concat(require('edgy-group.stl').get_statusline('bottom'))
    local mid_width = math.floor(vim.api.nvim_eval_statusline(mid_section, {}).width / 2)
    local nb_spaces = mid_screen - left_components_length - mid_width
    local left_padding = string.rep(' ', nb_spaces > 0 and nb_spaces - 1 or 0)
    self.text = left_padding
  end,
  provider = function(self)
    -- vim.schedule(update_highlights)
    return self.text
  end,
  update = { 'ModeChanged' },
  hl = { bg = 'none' },
}

local Edgy = {
  init = function(self) self.text = table.concat(require('edgy-group.stl').get_statusline('bottom')) end,
  provider = function(self) return self.text end,
  hl = { bg = 'none' },
}

return {
  LeftAlignment = LeftAlignment,
  Edgy = Edgy,
}
