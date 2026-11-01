---@class InlinePrompt.Providers.Claude
local M = {}

---Build the command that reads the prompt from stdin and prints the result.
---@public
---@param model InlinePrompt.Model
---@return string[]
function M.command(model)
  local cmd = { 'claude', '--print', '--model', model.id }

  if model.effort then
    vim.list_extend(cmd, { '--effort', model.effort })
  end
  if model.thinking == false then
    vim.list_extend(cmd, { '--settings', '{"alwaysThinkingEnabled":false}' })
  end

  return vim.list_extend(cmd, {
    -- Replaces the agent prompt and disables every extension to keep the response fast.
    '--system-prompt',
    'You are a text editing tool inside a text editor.',
    '--tools',
    '',
    '--setting-sources',
    '',
    '--strict-mcp-config',
    '--disable-slash-commands',
    '--no-session-persistence',
  })
end

return M
