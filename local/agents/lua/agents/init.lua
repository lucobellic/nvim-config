local M = {}

---@param opts table<string, AgentsOpts>
function M.setup(opts)
  local AgentManager = require('agents.agent-manager')
  local AgentRegistry = require('agents.agent-registry')
  AgentRegistry.setup()
  opts = opts or {}
  vim.iter(opts):each(function(name, agent_opts)
    local agent_manager = AgentManager.new(vim.tbl_deep_extend('force', {
      display_name = name,
      leader = '<leader>l' .. name:sub(1, 1),
    }, agent_opts or {}))
    agent_manager.opts.on_focus = function(agent)
      agent_manager.last_visited_agent = agent
      AgentRegistry.update_last_used(agent_manager)
    end
    agent_manager:setup_commands_and_keymaps(agent_manager.opts)
    agent_manager:setup_autocmds()
    AgentRegistry.register(agent_manager)
  end)
end

return M
