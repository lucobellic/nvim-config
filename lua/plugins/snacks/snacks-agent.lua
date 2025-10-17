local function send_to_agent(picker)
  local selected = picker:selected({ fallback = true })

  ---@type string[]
  local items = vim.iter(selected):map(function(item) return item.cwd .. '/' .. item.file end):totable()

  picker:close()

  local agent_manager = vim.env.INSIDE_DOCKER and require('util.agents.cursor').manager
    or require('util.agents.opencode').manager

  if agent_manager then
    local text = table.concat(items, ' ' .. agent_manager.newline .. ' ')
    agent_manager:send(text)
  end
end

return {
  'folke/snacks.nvim',
  optional = true,
  opts = {
    picker = {
      actions = {
        agent_send = function(picker) send_to_agent(picker) end,
      },
      win = {
        input = {
          keys = {
            ['<a-a>'] = {
              'agent_send',
              mode = { 'n', 'i' },
            },
          },
        },
      },
    },
  },
}
