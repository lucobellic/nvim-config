local mode_helpers = require('plugins.ui.heirline.components.mode')

local CPU = {
  init = function() return require('plugins.ui.heirline.utils.system').start_auto_update() end,
  provider = function() return require('plugins.ui.heirline.utils.system').system_stats_cache.cpu end,
  update = {
    'User',
    pattern = { 'CpuUpdated', 'ModeChanged' },
  },
  hl = mode_helpers.primary_highlight,
}

local GPU = {
  init = function() return require('plugins.ui.heirline.utils.system').start_auto_update() end,
  provider = function() return require('plugins.ui.heirline.utils.system').system_stats_cache.gpu end,
  update = {
    'User',
    pattern = { 'GpuUpdated', 'ModeChanged' },
  },
  hl = mode_helpers.primary_highlight,
}

local Memory = {
  init = function() return require('plugins.ui.heirline.utils.system').start_auto_update() end,
  provider = function() return require('plugins.ui.heirline.utils.system').system_stats_cache.memory end,
  update = {
    'User',
    pattern = { 'MemoryUpdated', 'ModeChanged' },
  },
  hl = mode_helpers.primary_highlight,
}

return {
  CPU = CPU,
  GPU = GPU,
  Memory = Memory,
}
