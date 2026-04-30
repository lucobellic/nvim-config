local Handler = require('plugins.ui.incline.handler')

---@class EdgyHandler : InclineHandler
local EdgyHandler = Handler:new({
  filetypes = {
    'neotest-output-panel',
    'neotest-summary',
    'noice',
    'Trouble',
    'OverseerList',
    'Outline',
    'trouble',
    'copilot-chat',
    'aerial',
  },
  titles = {
    ['neotest-output-panel'] = 'neotest',
    ['neotest-summary'] = 'neotest',
    noice = 'noice',
    Trouble = 'trouble',
    OverseerList = 'overseer',
    Outline = 'outline',
    aerial = 'aerial',
  },
})

function EdgyHandler:match(props) return vim.tbl_contains(self.filetypes, vim.bo[props.buf].filetype) end

function EdgyHandler:render(props)
  local filetype = vim.bo[props.buf].filetype
  local name = self.titles[filetype] or filetype

  if filetype == 'trouble' then
    local win_trouble = vim.w[props.win].trouble
    name = (win_trouble and win_trouble.mode ~= '' and win_trouble.mode) or 'trouble'
  end

  local title = ' ' .. name .. ' '
  return { { title, group = props.focused and 'FloatTitle' or 'Title' } }
end

return EdgyHandler
