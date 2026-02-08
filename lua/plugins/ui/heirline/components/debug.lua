local mode_helpers = require('plugins.ui.heirline.components.mode')
local colors = require('plugins.ui.heirline.colors').colors

local Molten = {
  condition = function() return package.loaded.molten end,
  init = function(self)
    local kernels = require('molten.status').kernels()
    self.text = kernels ~= '' and '  (' .. kernels .. ') ' or ''
    require('plugins.ui.heirline.utils.width_tracker').add(self.text)
  end,
  provider = function(self) return self.text end,
  hl = mode_helpers.secondary_highlight,
}

local Dap = {
  condition = function()
    local ok, dap = pcall(require, 'dap')
    return ok and dap.session() ~= nil
  end,
  init = function(self)
    self.text = '  ' .. require('dap').status()
    require('plugins.ui.heirline.utils.width_tracker').add(self.text)
  end,
  provider = function(self) return self.text end,
  hl = mode_helpers.primary_highlight,
}

local MacroRec = {
  condition = function() return vim.fn.reg_recording() ~= '' and vim.o.cmdheight == 0 end,
  init = function(self)
    self.text = ' ' .. vim.fn.reg_recording()
    require('plugins.ui.heirline.utils.width_tracker').add(self.text)
  end,
  provider = function(self) return self.text end,
  hl = { fg = colors.orange, italic = true },
}

return {
  Molten = Molten,
  Dap = Dap,
  MacroRec = MacroRec,
}
