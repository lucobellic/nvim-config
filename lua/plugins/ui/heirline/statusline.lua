local ai = require('plugins.ui.heirline.components.ai')
local debug = require('plugins.ui.heirline.components.debug')
local edgy = require('plugins.ui.heirline.components.edgy')
local git = require('plugins.ui.heirline.components.git')
local info = require('plugins.ui.heirline.components.info')
local mode = require('plugins.ui.heirline.components.mode')
local system = require('plugins.ui.heirline.components.system')
local tasks = require('plugins.ui.heirline.components.tasks')

local Left = { mode.ViMode, git.Git, info.Separator, debug.Dap, debug.Molten, debug.MacroRec }
local Center = { edgy.LeftAlignment, info.Separator, edgy.Edgy, info.Separator }
local Align = { provider = '%=', hl = { bg = 'none' } }
local SystemStats = {
  mode.PrimarySpace,
  system.CPU,
  system.GPU,
  system.Memory,
}
local Right = {
  tasks.Overseer,
  info.LspProgress,
  ai.Sidekick,
  -- ai.Copilot,
  ai.CodeCompanion,
  -- SystemStats,
  info.SearchCount,
  info.Separator,
  info.Date,
}

edgy.highlight_change_setup()
return { Left, Center, Align, Right }
