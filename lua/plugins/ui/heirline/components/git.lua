local mode_helpers = require('plugins.ui.heirline.components.mode')

local Git = {
  condition = function() return require('heirline.conditions').is_git_repo() end,
  init = function(self)
    ---@diagnostic disable-next-line: undefined-field
    self.status_dict = vim.b.gitsigns_status_dict
    self.text = ' ' .. self.status_dict.head .. ' '
    if #self.text > 20 then
      self.text = string.sub(self.text, 1, 20) .. '...'
    end
    require('plugins.ui.heirline.utils.width_tracker').add(self.text)
  end,
  provider = function(self) return self.text end,
  hl = mode_helpers.primary_highlight,
}

return {
  Git = Git,
}
