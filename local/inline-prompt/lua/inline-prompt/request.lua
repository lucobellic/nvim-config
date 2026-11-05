local config = require('inline-prompt.config')
local notify = require('inline-prompt.notify')
local prompt = require('inline-prompt.prompt')
local rain = require('inline-prompt.rain')
local status = require('inline-prompt.status')

---@class InlinePrompt.Request
---@field buf integer
---@field mark integer
---@field original string[] Text at submission, used to detect edits made during the request
---@field cancelled? boolean
---@field stop_rain? fun()
---@field process? vim.SystemObj

---@class InlinePrompt.RequestModule
local M = {}

local namespace = vim.api.nvim_create_namespace('inline-prompt')

---@type table<InlinePrompt.Request, true>
local requests = {}

---Current range of a mark, which follows edits made while the request runs.
---@param buf integer
---@param mark integer
---@return InlinePrompt.Range?
local function mark_range(buf, mark)
  local position = vim.api.nvim_buf_get_extmark_by_id(buf, namespace, mark, { details = true })
  -- Reloading a buffer can remove the mark.
  if #position == 0 then
    return nil
  end
  return {
    start_row = position[1],
    start_col = position[2],
    end_row = position[3].end_row,
    end_col = position[3].end_col,
  }
end

---@param request InlinePrompt.Request
---@param stdout string
local function apply(request, stdout)
  local lines = prompt.parse(stdout)
  if not lines then
    notify('Unexpected provider output, result discarded\n' .. vim.trim(stdout), vim.log.levels.WARN)
    return
  end

  local range = mark_range(request.buf, request.mark)
  local current = range
    and vim.api.nvim_buf_get_text(request.buf, range.start_row, range.start_col, range.end_row, range.end_col, {})

  if not vim.deep_equal(current, request.original) then
    notify('Selection changed during the request, result discarded', vim.log.levels.WARN)
    return
  end

  vim.api.nvim_buf_set_text(request.buf, range.start_row, range.start_col, range.end_row, range.end_col, lines)
end

---@param request InlinePrompt.Request
---@param result vim.SystemCompleted
local function on_exit(request, result)
  requests[request] = nil
  status.update(vim.tbl_count(requests))
  request.stop_rain()
  if not vim.api.nvim_buf_is_loaded(request.buf) then
    return
  end

  if not request.cancelled then
    if result.code ~= 0 then
      local output = result.stderr ~= '' and result.stderr or result.stdout
      notify(('Request failed with code %d\n%s'):format(result.code, vim.trim(output)), vim.log.levels.ERROR)
    else
      apply(request, result.stdout)
    end
  end

  M.unmark(request.buf, request.mark)
end

---Highlight the range. The mark follows it when lines above change during the request.
---@public
---@param buf integer
---@param range InlinePrompt.Range
---@return integer mark
function M.mark(buf, range)
  return vim.api.nvim_buf_set_extmark(buf, namespace, range.start_row, range.start_col, {
    end_row = range.end_row,
    end_col = range.end_col,
    hl_group = 'Visual',
    right_gravity = false,
    end_right_gravity = true,
  })
end

---@public
---@param buf integer
---@param mark integer
function M.unmark(buf, mark) vim.api.nvim_buf_del_extmark(buf, namespace, mark) end

---Run the command in the background and replace the marked range with its result.
---@public
---@param buf integer
---@param mark integer
---@param range InlinePrompt.Range
---@param instruction string
---@param command string[]
function M.send(buf, mark, range, instruction, command)
  local selection = vim.api.nvim_buf_get_text(buf, range.start_row, range.start_col, range.end_row, range.end_col, {})
  ---@type InlinePrompt.Request
  local request = { buf = buf, mark = mark, original = selection }
  requests[request] = true
  status.update(vim.tbl_count(requests))
  request.stop_rain = rain.start(buf, function() return mark_range(buf, mark) end)

  request.process = vim.system(command, {
    stdin = prompt.build(buf, range, instruction, selection),
    text = true,
    timeout = config.options.timeout,
  }, vim.schedule_wrap(function(result) on_exit(request, result) end))
end

---Stop every running request and leave the buffers unchanged.
---@public
function M.cancel()
  vim.iter(vim.tbl_keys(requests)):each(function(request)
    request.cancelled = true
    request.process:kill('sigterm')
  end)
end

return M
