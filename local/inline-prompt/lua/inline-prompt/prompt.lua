local config = require('inline-prompt.config')

---@class InlinePrompt.Prompt
local M = {}

local TEMPLATE = [[
Edit the text as requested. Everything you need is below, so do not read files or run commands.
Reply with only the text that replaces the <selection> content, wrapped in <replacement> tags.
Keep the exact indentation and style. No Markdown fences, no explanation.
When the selection is empty, reply with the text to insert.

File: %s
Filetype: %s
Request: %s

<before>
%s
</before>
<selection>
%s
</selection>
<after>
%s
</after>]]

---Build the text sent to the provider.
---@public
---@param buf integer
---@param range InlinePrompt.Range
---@param instruction string
---@param selection string[]
---@return string
function M.build(buf, range, instruction, selection)
  local context_lines = config.options.context_lines
  local last_row = vim.api.nvim_buf_line_count(buf) - 1
  local context_end_row = math.min(last_row, range.end_row + context_lines)
  local context_end_col = #vim.api.nvim_buf_get_lines(buf, context_end_row, context_end_row + 1, true)[1]
  local before = vim.api.nvim_buf_get_text(
    buf,
    math.max(0, range.start_row - context_lines),
    0,
    range.start_row,
    range.start_col,
    {}
  )
  local after = vim.api.nvim_buf_get_text(buf, range.end_row, range.end_col, context_end_row, context_end_col, {})

  return TEMPLATE:format(
    vim.api.nvim_buf_get_name(buf),
    vim.bo[buf].filetype,
    instruction,
    table.concat(before, '\n'),
    table.concat(selection, '\n'),
    table.concat(after, '\n')
  )
end

-- Tags protect leading indentation, which the command line tools can trim from their output.
---Extract the replacement lines from the provider output.
---@public
---@param stdout string
---@return string[]?
function M.parse(stdout)
  local text = stdout:match('<replacement>\n?(.*)</replacement>')
  return text and vim.split((text:gsub('\n$', '')), '\n')
end

return M
