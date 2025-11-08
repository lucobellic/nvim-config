local mode_helpers = require('plugins.ui.heirline.components.mode')
local colors = require('plugins.ui.heirline.colors').colors

local function hsv_to_hex(h, s, v)
  local r, g, b

  if s == 0 then
    r, g, b = v, v, v
  else
    h = h * 6
    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s)
    local q = v * (1 - s * f)
    local t = v * (1 - s * (1 - f))
    i = i % 6

    if i == 0 then
      r, g, b = v, t, p
    elseif i == 1 then
      r, g, b = q, v, p
    elseif i == 2 then
      r, g, b = p, v, t
    elseif i == 3 then
      r, g, b = p, q, v
    elseif i == 4 then
      r, g, b = t, p, v
    elseif i == 5 then
      r, g, b = v, p, q
    end
  end

  local ir = math.floor(r * 255 + 0.5)
  local ig = math.floor(g * 255 + 0.5)
  local ib = math.floor(b * 255 + 0.5)
  return string.format('#%02x%02x%02x', ir, ig, ib), r, g, b
end

local function setup_rainbow_highlights(base_names, count, interval_ms)
  interval_ms = interval_ms or 50
  count = count or 10
  base_names = base_names or { 'EdgyGroupInactiveBottom', 'EdgyGroupSeparatorInactiveBottom' }

  local positions = {}
  for i = 1, count do
    positions[i] = (i - 1) / count
  end

  local offset = 0.0
  local offset_step = 0.01

  local timer = vim.loop.new_timer()
  local running = true

  local function update()
    for _, base in ipairs(base_names) do
      for i = 1, count do
        local hue = positions[i] + offset
        hue = hue - math.floor(hue)
        local s, v = 0.85, 0.9
        local hex, r, g, b = hsv_to_hex(hue, s, v)
        local luminance = 0.299 * r + 0.587 * g + 0.114 * b
        local fg = luminance > 0.5 and '#000000' or '#ffffff'
        local hl_name = base .. tostring(i)
        vim.api.nvim_set_hl(0, hl_name, { bg = hex, fg = fg })
      end
    end

    offset = offset - offset_step
    if offset < 0 then
      offset = offset + 1
    end
  end

  timer:start(
    0,
    interval_ms,
    vim.schedule_wrap(function()
      if not running then
        return
      end
      update()
    end)
  )

  local handle = {}
  function handle.stop()
    if not running then
      return
    end
    running = false
    timer:stop()
    timer:close()
    timer = nil
  end

  return handle
end

local function highlight_change_setup()
  local timer = vim.uv.new_timer()
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

  vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
    ---@diagnostic disable-next-line: undefined-field
    callback = function()
      if timer then
        if timer:is_active() then
          timer:stop()
        end
        timer:start(50, 0, vim.schedule_wrap(function() update_highlights() end))
      end
    end,
  })
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
  provider = function(self) return self.text end,
  hl = { bg = 'none' },
}

local Edgy = {
  init = function(self) self.text = table.concat(require('edgy-group.stl').get_statusline('bottom')) end,
  provider = function(self) return self.text end,
  hl = { bg = 'none' },
}

return {
  setup_rainbow_highlights = setup_rainbow_highlights,
  highlight_change_setup = highlight_change_setup,
  LeftAlignment = LeftAlignment,
  Edgy = Edgy,
}
