local config = require('inline-prompt.config')
local notify = require('inline-prompt.notify')
local range_util = require('inline-prompt.range')
local requests = require('inline-prompt.request')

---@class InlinePrompt
local M = {}

---Replace the selection or insert at the cursor with the result of a request.
---Without an instruction, ask for one first. With an instruction, normal mode targets the current line.
---@public
---@param model_name? string Defaults to `options.model`
---@param instruction? string
function M.prompt(model_name, instruction)
  model_name = model_name or config.options.model
  local model = config.options.models[model_name]
  local buf = vim.api.nvim_get_current_buf()

  if not model then
    return notify('Unknown model: ' .. model_name, vim.log.levels.ERROR)
  end

  local command = require('inline-prompt.providers.' .. model.provider).command(model)
  if vim.fn.executable(command[1]) == 0 then
    return notify('Executable not found: ' .. command[1], vim.log.levels.ERROR)
  end
  if not vim.bo[buf].modifiable then
    return notify('Buffer is not modifiable', vim.log.levels.WARN)
  end

  local range = range_util.current(instruction ~= nil)
  vim.cmd.normal({ args = { vim.keycode('<Esc>') }, bang = true })
  local mark = requests.mark(buf, range)

  ---@param input? string
  local function submit(input)
    if not input or input == '' then
      return requests.unmark(buf, mark)
    end
    requests.send(buf, mark, range, input, command)
  end

  if instruction then
    return submit(instruction)
  end
  vim.ui.input({ prompt = ('Inline prompt (%s): '):format(model_name) }, submit)
end

---Stop every running request and leave the buffers unchanged.
---@public
function M.cancel() requests.cancel() end

---Text for a statusline: spinner or check icon, the logo, and the number of running requests from two.
---@public
---@return string
function M.status() return require('inline-prompt.status').render() end

---@public
---@param opts? InlinePrompt.Options
function M.setup(opts) config.setup(opts) end

return M
