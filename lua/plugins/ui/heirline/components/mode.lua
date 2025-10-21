local colors = require('plugins.ui.heirline.colors').colors

local primary_mode_colors = {
  n = { fg = colors.dark_gray },
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

local secondary_mode_colors = {
  n = { fg = colors.dark_gray },
  i = { fg = colors.green },
  v = { fg = colors.orange },
  V = { fg = colors.orange },
  ['\22'] = { fg = colors.orange },
  c = { fg = colors.blue },
  s = { fg = colors.purple },
  S = { fg = colors.purple },
  ['\19'] = { fg = colors.purple },
  R = { fg = colors.red },
  r = { fg = colors.red },
  ['!'] = { fg = colors.blue },
  t = { fg = colors.purple },
}

local function get_mode()
  local mode = vim.fn.mode(1) or 'n'
  return mode:sub(1, 1)
end

local primary_highlight = function() return primary_mode_colors[get_mode()] end
local secondary_highlight = function() return secondary_mode_colors[get_mode()] end

local PrimarySpace = {
  provider = ' ',
  hl = primary_highlight,
}

local SecondarySpace = {
  provider = ' ',
  hl = secondary_highlight,
}

vim.api.nvim_create_autocmd('ModeChanged', {
  callback = vim.schedule_wrap(function() vim.api.nvim_exec_autocmds('User', { pattern = 'ModeChanged' }) end),
})

local ViMode = {
  init = function() left_components_length = 4 end,
  provider = function() return '  ' end,
  hl = primary_highlight,
}

return {
  primary_highlight = primary_highlight,
  secondary_highlight = secondary_highlight,
  PrimarySpace = PrimarySpace,
  SecondarySpace = SecondarySpace,
  ViMode = ViMode,
  get_mode = get_mode,
}
