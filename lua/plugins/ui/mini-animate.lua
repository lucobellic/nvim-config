local latest_timestamp = 0
local throttle_ms = 50
local throttle_scroll = function()
  local cur_time = vim.loop.hrtime()
  local res = 0.000001 * (cur_time - latest_timestamp) > throttle_ms
  if res then
    latest_timestamp = cur_time
  end
  return res
end

return {
  'echasnovski/mini.animate',
  enabled = not vim.g.neovide and not vim.g.started_by_firenvim,
  opts = {
    open = {
      enable = false,
    },
    close = {
      enable = false,
    },
    cursor = {
      enable = false,
    },
    scroll = {
      enable = true,
      subscroll = require('mini.animate').gen_subscroll.equal({ predicate = throttle_scroll }),
    },
    resize = {
      enable = false, -- Do not work while holding resize key
    },
  },
}
