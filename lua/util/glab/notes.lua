local M = {}

---Displays an error notification with the glab title
---@param message string The error message to display
local function notify_error(message) vim.notify(message, vim.log.levels.ERROR, { title = 'glab' }) end

---Executes a shell command and returns its output or handles errors
---@param command string The command to execute
---@param args string[] Command arguments
---@param fallback_error string Error message to show if command fails without stderr
---@param notify boolean? Whether to notify the user on error, defaults to true
---@return string[]? output Command output lines, or nil if failed
local function execute_command(command, args, fallback_error, notify)
  local Job = require('plenary.job')

  ---@diagnostic disable-next-line: missing-fields
  local job = Job:new({ command = command, args = args })
  local output = job:sync()

  if job.code ~= 0 or not output then
    local error_message = job.code ~= 0 and table.concat(job:stderr_result(), '\n') or fallback_error
    if notify and notify ~= false then
      notify_error(error_message)
    end
    return nil
  end

  return output
end

function M.get_unresolved_discussion_notes()
  local state = require('gitlab.state')
  local u = require('gitlab.utils')

  local discussions = u.ensure_table(state.DISCUSSION_DATA and state.DISCUSSION_DATA.discussions or {})
  local unlinked_discussions =
    u.ensure_table(state.DISCUSSION_DATA and state.DISCUSSION_DATA.unlinked_discussions or {})

  local all_discussions = {}
  for _, d in ipairs(discussions) do
    table.insert(all_discussions, d)
  end
  for _, d in ipairs(unlinked_discussions) do
    table.insert(all_discussions, d)
  end

  return vim
    .iter(all_discussions)
    :filter(function(discussion)
      if discussion.notes and type(discussion.notes) == 'table' and #discussion.notes > 0 then
        local first_note = discussion.notes[1]
        return first_note.resolvable and not first_note.resolved
      end
      return false
    end)
    :map(function(discussion) return discussion.notes end)
    :totable()
end

function M.get_code_from_position(note)
  local position = note.position
  local file_path = position.new_path or position.old_path
  local sha = position.head_sha

  -- Get the file content at the specific commit using plenary.job
  local git_show_cmd = { 'show', string.format('%s:%s', sha, file_path) }
  local result = execute_command('git', git_show_cmd, 'Failed to get file content from git', false)

  -- Extract the relevant lines based on position
  local start_line, end_line
  if position.line_range then
    start_line = position.line_range.start.new_line or position.line_range.start.old_line
    end_line = position.line_range['end'].new_line or position.line_range['end'].old_line
  else
    start_line = position.new_line or position.old_line
    end_line = start_line
  end

  -- Extract the code block using vim.iter
  local code_lines = vim.iter(result):slice(start_line, end_line + 1):totable()
  return table.concat(code_lines, '\n')
end

function M.get_unresolved_discussions()
  -- TODO: Update gitlab to refresh discussion correctly
  local discussions = require('gitlab.actions.discussions')
  discussions.load_discussions()
  unresolved_discussion_notes = M.get_unresolved_discussion_notes()

  -- Process the example data
  local processed_notes = {}
  for _, discussion in ipairs(unresolved_discussion_notes) do
    for _, note in ipairs(discussion) do
      local result = {
        body = note.body,
        code = vim.F.npcall(M.get_code_from_position, note),
        path = note.position and note.position.new_path or nil,
      }
      table.insert(processed_notes, result)
    end
  end

  -- Build result string
  local result_str = {}
  for i, note in ipairs(processed_notes) do
    if note.body then
      table.insert(result_str, '\n### Note ' .. i)
      table.insert(result_str, 'Comment:\n' .. (note.body or ''))
      table.insert(result_str, 'Path: ' .. (note.path or 'Not Found'))
      table.insert(result_str, 'Code:\n' .. (note.code or 'Not found'))
    end
  end

  return table.concat(result_str, '\n')
end

return M
