--- Diagnostic float that lists the available code actions under the message.
---@class LspUi.Diagnostic
local M = {}

local code_actions = require('lsp-ui.code-actions')
local config = require('lsp-ui.config')

local namespace = vim.api.nvim_create_namespace('lsp-ui.diagnostic')

---@param index integer
---@param choice LspUi.CodeAction
---@return string
local function action_line(index, choice) return string.format('%d. %s', index, choice.action.title) end

---@param bufnr integer
---@param row integer
---@param end_col integer
---@param hl_group string
local function highlight(bufnr, row, end_col, hl_group)
  vim.api.nvim_buf_set_extmark(bufnr, namespace, row, 0, { end_col = end_col, hl_group = hl_group })
end

---@param float_bufnr integer
---@param first_row integer
---@param lines string[]
local function highlight_actions(float_bufnr, first_row, lines)
  local highlights = config.options.highlights
  vim.iter(ipairs(lines)):each(function(offset, line)
    local row = first_row + offset - 1
    highlight(float_bufnr, row, #line, highlights.action)
    highlight(float_bufnr, row, #line:match('^%d+%.'), highlights.index)
  end)
end

--- Same markdown setup as the built in LSP hover float.
---@param float_winid integer
---@param float_bufnr integer
local function render_markdown(float_winid, float_bufnr)
  vim.wo[float_winid].conceallevel = 2
  vim.wo[float_winid].concealcursor = ''
  vim.bo[float_bufnr].filetype = 'markdown'
  vim.treesitter.start(float_bufnr, 'markdown')
end

--- Grow the float so every line fits without wrapping when possible.
---@param float_winid integer
---@param float_bufnr integer
local function resize(float_winid, float_bufnr)
  local lines = vim.api.nvim_buf_get_lines(float_bufnr, 0, -1, false)
  local width = vim.iter(lines):fold(0, function(max, line) return math.max(max, vim.fn.strdisplaywidth(line)) end)
  vim.api.nvim_win_set_config(float_winid, { width = math.min(width, vim.o.columns - 4), height = #lines })
end

---@param float_winid integer
---@param float_bufnr integer
---@param actions LspUi.CodeAction[]
local function append_actions(float_winid, float_bufnr, actions)
  local lines = vim.iter(ipairs(actions)):map(action_line):totable()
  local separator_row = vim.api.nvim_buf_line_count(float_bufnr)

  vim.bo[float_bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(float_bufnr, -1, -1, false, { '', unpack(lines) })
  vim.bo[float_bufnr].modifiable = false

  highlight_actions(float_bufnr, separator_row + 1, lines)
  resize(float_winid, float_bufnr)
  -- Markdown renderers only redraw on text changes in the current buffer, and the float is not current
  vim.api.nvim_exec_autocmds('TextChanged', { buffer = float_bufnr, modeline = false })
end

--- Digit keys live in the float only, so counts like `3j` in the code buffer keep working.
---@param float_winid integer
---@param float_bufnr integer
---@param source_winid integer
---@param diagnostic vim.Diagnostic
---@param actions LspUi.CodeAction[]
local function map_actions(float_winid, float_bufnr, source_winid, diagnostic, actions)
  vim.iter(ipairs(actions)):each(function(index, choice)
    vim.keymap.set('n', tostring(index), function()
      vim.api.nvim_win_close(float_winid, true)
      vim.api.nvim_set_current_win(source_winid)
      code_actions.apply(diagnostic, choice)
    end, { buf = float_bufnr, nowait = true, desc = choice.action.title })
  end)
end

--- Open the diagnostic float, then add the code actions once the servers answer.
---@param diagnostic vim.Diagnostic
---@param bufnr integer
function M.open(diagnostic, bufnr)
  local source_winid = vim.api.nvim_get_current_win()
  local float_opts = vim.tbl_extend('force', config.options.diagnostic.float, { bufnr = bufnr })
  local float_bufnr, float_winid = vim.diagnostic.open_float(float_opts)
  if not float_bufnr or not float_winid then
    return
  end
  render_markdown(float_winid, float_bufnr)

  code_actions.request(bufnr, diagnostic, function(actions)
    actions = vim.list_slice(actions, 1, config.options.diagnostic.max_actions)
    if #actions == 0 or not vim.api.nvim_win_is_valid(float_winid) then
      return
    end
    append_actions(float_winid, float_bufnr, actions)
    map_actions(float_winid, float_bufnr, source_winid, diagnostic, actions)
  end)
end

---@param opts vim.diagnostic.JumpOpts
function M.jump(opts)
  vim.diagnostic.jump(vim.tbl_extend('force', opts, {
    on_jump = function(diagnostic, bufnr)
      if diagnostic then
        M.open(diagnostic, bufnr)
      end
    end,
  }))
end

return M
