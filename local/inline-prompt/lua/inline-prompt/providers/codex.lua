---@class InlinePrompt.Providers.Codex
local M = {}

---Build the command that reads the prompt from stdin and prints the result.
---@public
---@param model InlinePrompt.Model
---@return string[]
function M.command(model)
  local cmd = {
    'codex',
    'exec',
    '--skip-git-repo-check',
    '--sandbox',
    'read-only',
    '--ephemeral',
    -- Same isolation as Claude, the prompt already carries the needed context.
    '--ignore-user-config',
    '--ignore-rules',
    '--config',
    'project_doc_max_bytes=0',
    '--model',
    model.id,
  }

  if model.effort then
    vim.list_extend(cmd, { '--config', ('model_reasoning_effort="%s"'):format(model.effort) })
  end

  return vim.list_extend(cmd, { '-' })
end

return M
