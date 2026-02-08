local mode_helpers = require('plugins.ui.heirline.components.mode')

local LspProgress = {
  provider = function() return require('lsp-progress').progress() .. ' ' end,
  update = {
    'User',
    pattern = { 'LspProgressStatusUpdated', 'ModeChanged' },
    callback = vim.schedule_wrap(function() vim.cmd('redrawstatus') end),
  },
  hl = mode_helpers.secondary_highlight,
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
    return self.search
        and string.format('[%d/%d] ', self.search.current, math.min(self.search.total, self.search.maxcount))
      or ''
  end,
  hl = mode_helpers.secondary_highlight,
}

local Ruler = {
  provider = ' %3l:%-3c ',
  hl = mode_helpers.secondary_highlight,
}

local Date = {
  provider = function() return '  ' .. os.date('%Hh%M') .. ' ' end,
  hl = mode_helpers.primary_highlight,
}

local Separator = {
  init = function(self)
    self.text = mode_helpers.get_mode() == 'n' and ' ' or '┃'
    require('plugins.ui.heirline.utils.width_tracker').add(self.text)
  end,
  provider = function(self) return self.text end,
  hl = mode_helpers.secondary_highlight,
}

local LazyUpdates = {
  condition = require('lazy.status').has_updates,
  init = function(self)
    self.text = require('lazy.status').updates()
    require('plugins.ui.heirline.utils.width_tracker').add(self.text)
  end,
  provider = function(self) return self.text end,
  hl = mode_helpers.primary_highlight,
}

return {
  LazyUpdates = LazyUpdates,
  LspProgress = LspProgress,
  SearchCount = SearchCount,
  Ruler = Ruler,
  Date = Date,
  Separator = Separator,
}
