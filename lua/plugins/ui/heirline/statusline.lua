local conditions = require('heirline.conditions')
local colors = require('plugins.ui.heirline.colors').colors

local mode_colors = {
  n = { fg = colors.darkgray },
  i = { bg = colors.green, fg = colors.black },
  v = { bg = colors.orange, fg = colors.black },
  V = { bg = colors.orange, fg = colors.black },
  ['\22'] = { bg = colors.orange, fg = colors.black },
  c = { bg = colors.blue, fg = colors.black },
  s = { bg = colors.purple, fg = colors.black },
  S = { bg = colors.purple, fg = colors.black },
  ['\19'] = { bg = colors.purple, fg = colors.black },
  R = { bg = colors.red, fg = colors.black },
  r = { bg = colors.red, fg = colors.black },
  ['!'] = { bg = colors.blue, fg = colors.black },
  t = { bg = colors.purple, fg = colors.black },
}

local highlight = function() return mode_colors[vim.fn.mode(1):sub(1, 1)] end

local left_components_length = 0

------------------------------------- Left -------------------------------------

local ViMode = {
  init = function() left_components_length = 4 end,
  provider = function() return '   ' end,
  hl = highlight,
}

local Git = {
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.text = ' ' .. self.status_dict.head .. ' '
    left_components_length = left_components_length + vim.api.nvim_eval_statusline(self.text, {}).width
  end,
  condition = conditions.is_git_repo,
  provider = function(self) return self.text end,
  hl = highlight,
}

------------------------------------ Center -------------------------------------

local Edgy = {
  init = function(self)
    local mid_screen = math.floor(vim.api.nvim_get_option('columns') / 2)
    local mid_section = table.concat(require('edgy-group.stl.statusline').get_statusline('bottom'))
    local mid_width = math.floor(vim.api.nvim_eval_statusline(mid_section, {}).width / 2)
    local nb_spaces = mid_screen - left_components_length - mid_width
    local left_padding = string.rep(' ', nb_spaces > 0 and nb_spaces or 0)
    self.text = left_padding .. mid_section
  end,
  provider = function(self) return self.text end,
}

------------------------------------ Right -------------------------------------

local copilot_icons = {
  Normal = ' ',
  InProgress = ' ',
  disabled = ' ',
  Warning = ' ',
  unknown = ' ',
}

local function get_copilot_icons()
  if copilot_client.is_disabled() then
    return copilot_icons.disabled
  end
  return copilot_icons[copilot_api.status.data.status] or copilot_icons.unknown
end

local Copilot = {
  condition = function()
    return not copilot_client.is_disabled() and copilot_client.buf_is_attached(vim.api.nvim_get_current_buf())
  end,
  provider = get_copilot_icons,
}

local SearchCount = {
  condition = function() return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0 end,
  init = function(self)
    local ok, search = pcall(vim.fn.searchcount)
    if ok and search.total then
      self.search = search
    end
  end,
  provider = function(self)
    local search = self.search
    return string.format('[%d/%d]', search.current, math.min(search.total, search.maxcount))
  end,
  hl = highlight,
}

local Left = { { ViMode }, { Git } }
local Center = { Edgy }
local Align = { provider = '%=' }
local Right = { Copilot, SearchCount }

return { Left, Center, Align, Right }
