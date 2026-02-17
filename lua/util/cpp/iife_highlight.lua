---@class IIFEHighlight
---@field enabled boolean Whether IIFE highlighting is enabled.
---@field ns_id integer Namespace ID for extmarks.
---@field query_cache vim.treesitter.Query? Cached compiled treesitter query for IIFE detection
---@field highlight string Highlight group to use for IIFE arguments
---@field priority integer Highlight priority for IIFE extmarks
local M = {
  enabled = true,
  ns_id = vim.api.nvim_create_namespace('iife_highlight'),
  query_cache = nil,
  highlight = 'CursorLine',
  priority = 100,
}

--- Treesitter query to match immediately invoked lambda expressions in C++.
--- Pattern: a call_expression whose function child is a lambda_expression.
--- We capture the argument_list (the invocation parentheses + arguments).
local query_string = [[
  (call_expression
    function: (lambda_expression)
    arguments: (argument_list) @iife_args)
]]

--- Get or create the treesitter query for IIFE detection.
---@return vim.treesitter.Query?
local function get_query()
  if M.query_cache ~= nil then
    return M.query_cache
  end

  local ok, query = pcall(vim.treesitter.query.parse, 'cpp', query_string)
  if not ok or not query then
    return nil
  end

  M.query_cache = query
  return query
end

--- Apply IIFE highlights to the given buffer.
---@param bufnr integer
local function highlight_iife(bufnr)
  bufnr = bufnr or 0
  vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)

  if not M.enabled then
    return
  end

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end

  local lang = parser:lang()
  if lang ~= 'cpp' then
    return
  end

  local tree = parser:parse()[1]
  if not tree then
    return
  end

  local query = get_query()
  if not query then
    return
  end

  vim
    .iter(query:iter_captures(tree:root(), bufnr))
    :filter(function(id, _) return query.captures[id] == 'iife_args' end)
    :each(function(_, node)
      local start_row, start_col, end_row, end_col = node:range()
      vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, start_row, start_col, {
        end_row = end_row,
        end_col = end_col,
        hl_group = M.highlight,
        priority = M.priority,
      })
    end)
end

function M.toggle()
  M.enabled = not M.enabled
  if M.enabled then
    -- Re-highlight all cpp buffers
    vim.iter(vim.api.nvim_list_bufs()):filter(vim.api.nvim_buf_is_loaded):each(highlight_iife)
  else
    -- Clear highlights from all buffers
    vim
      .iter(vim.api.nvim_list_bufs())
      :filter(vim.api.nvim_buf_is_loaded)
      :each(function(bufnr) vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1) end)
  end
  vim.notify(
    string.format('IIFE highlight %s', M.enabled and 'enabled' or 'disabled'),
    M.enabled and vim.log.levels.INFO or vim.log.levels.WARN,
    { title = 'IIFE Highlight' }
  )
end

function M.setup(opts)
  opts = opts or {}
  M.enabled = opts.enabled ~= false
  local group = vim.api.nvim_create_augroup('IIFEHighlight', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
    group = group,
    pattern = { '*.cpp', '*.cxx', '*.cc', '*.hpp', '*.hxx', '*.h' },
    callback = function(ev) highlight_iife(ev.buf) end,
  })
end

return M
