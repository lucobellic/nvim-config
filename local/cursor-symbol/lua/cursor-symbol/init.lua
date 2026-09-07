---@class CursorSymbol
local M = {}

local namespace = vim.api.nvim_create_namespace('cursor-symbol')
local lsp_namespace = vim.api.nvim_create_namespace('nvim.lsp.references')
local enabled = true
---@type table<integer, integer>
local generations = {}

---@class CursorSymbol.Capture
---@field node TSNode
---@field name string
---@field kind string

---@param node TSNode
---@param scopes table<string, TSNode>
---@param root TSNode
---@return TSNode[]
local function scope_chain(node, scopes, root)
  local chain = {}
  local current = node

  while current do
    if scopes[tostring(current:id())] then
      chain[#chain + 1] = current
    end
    current = current:parent()
  end

  if #chain == 0 or tostring(chain[#chain]:id()) ~= tostring(root:id()) then
    chain[#chain + 1] = root
  end

  return chain
end

---@param scope TSNode
---@param name string
---@return string
local function definition_key(scope, name) return tostring(scope:id()) .. '\0' .. name end

---@param node TSNode
---@param name string
---@param scopes table<string, TSNode>
---@param root TSNode
---@param definitions table<string, CursorSymbol.Capture>
---@return CursorSymbol.Capture?
local function resolve_definition(node, name, scopes, root, definitions)
  for _, scope in ipairs(scope_chain(node, scopes, root)) do
    local definition = definitions[definition_key(scope, name)]
    if definition then
      return definition
    end
  end
end

---@param bufnr integer
local function treesitter_highlight(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end

  local language = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype) or vim.bo[bufnr].filetype
  local query = vim.treesitter.query.get(language, 'locals')
  local tree = parser:parse()[1]
  local cursor_node = vim.treesitter.get_node({ bufnr = bufnr })
  if not query or not tree or not cursor_node then
    return
  end

  local root = tree:root()
  local scopes = { [tostring(root:id())] = root }
  ---@type CursorSymbol.Capture[]
  local captures = {}

  for capture_id, node in query:iter_captures(root, bufnr) do
    local capture = query.captures[capture_id]
    if capture == 'local.scope' then
      scopes[tostring(node:id())] = node
    elseif
      capture == 'local.reference'
      or capture == 'local.definition.var'
      or capture == 'local.definition.parameter'
    then
      captures[#captures + 1] = {
        kind = capture,
        node = node,
        name = vim.treesitter.get_node_text(node, bufnr),
      }
    end
  end

  ---@type table<string, CursorSymbol.Capture>
  local definitions = {}
  for _, capture in ipairs(captures) do
    if vim.startswith(capture.kind, 'local.definition.') then
      local scope = scope_chain(capture.node, scopes, root)[1]
      definitions[definition_key(scope, capture.name)] = definitions[definition_key(scope, capture.name)] or capture
    end
  end

  local cursor_ancestors = {}
  local ancestor = cursor_node
  while ancestor do
    cursor_ancestors[tostring(ancestor:id())] = true
    ancestor = ancestor:parent()
  end

  local target
  for _, capture in ipairs(captures) do
    if cursor_ancestors[tostring(capture.node:id())] then
      target = resolve_definition(capture.node, capture.name, scopes, root, definitions)
      if target then
        break
      end
    end
  end
  if not target then
    return
  end

  local seen = {}
  ---@type CursorSymbol.Capture[]
  local matches = {}
  for _, capture in ipairs(captures) do
    local definition = resolve_definition(capture.node, capture.name, scopes, root, definitions)
    local node_id = tostring(capture.node:id())
    if definition and definition.node:id() == target.node:id() and not seen[node_id] then
      seen[node_id] = true
      matches[#matches + 1] = capture
    end
  end

  if #matches < 2 then
    return
  end

  for _, capture in ipairs(matches) do
    local start_row, start_col, end_row, end_col = capture.node:range()
    vim.api.nvim_buf_set_extmark(bufnr, namespace, start_row, start_col, {
      end_row = end_row,
      end_col = end_col,
      hl_group = capture.node:id() == target.node:id() and 'LspReferenceWrite' or 'LspReferenceRead',
      priority = vim.hl.priorities.user,
    })
  end
end

---@param row integer
---@param col integer
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@return boolean
local function position_in_range(row, col, start_row, start_col, end_row, end_col)
  local after_start = row > start_row or (row == start_row and col >= start_col)
  local before_end = row < end_row or (row == end_row and col < end_col)
  return after_start and before_end
end

---@param bufnr integer
---@return boolean
local function cursor_on_reference(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local position = { row, col }

  for _, highlight_namespace in ipairs({ namespace, lsp_namespace }) do
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, highlight_namespace, position, position, {
      details = true,
      overlap = true,
    })
    for _, extmark in ipairs(extmarks) do
      local details = extmark[4]
      if
        details.end_row
        and details.end_col
        and position_in_range(row, col, extmark[2], extmark[3], details.end_row, details.end_col)
      then
        return true
      end
    end
  end

  return false
end

---@param bufnr integer
---@param client vim.lsp.Client
---@param generation integer
local function lsp_highlight(bufnr, client, generation)
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

  ---@param error? lsp.ResponseError
  ---@param references? lsp.DocumentHighlight[]
  local function handler(error, references)
    if error or not references or #references < 2 or generations[bufnr] ~= generation or not enabled then
      return
    end
    vim.lsp.util.buf_highlight_references(bufnr, references, client.offset_encoding)
  end

  client:request('textDocument/documentHighlight', params, handler, bufnr)
end

---@public
---@param bufnr? integer
function M.clear(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  generations[bufnr] = (generations[bufnr] or 0) + 1
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.lsp.util.buf_clear_references(bufnr)
end

---@public
function M.highlight()
  if not enabled or vim.api.nvim_get_mode().mode ~= 'n' then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  if cursor_on_reference(bufnr) then
    return
  end

  M.clear(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/documentHighlight' })
  if clients[1] then
    lsp_highlight(bufnr, clients[1], generations[bufnr])
  else
    treesitter_highlight(bufnr)
  end
end

---@public
---@return boolean enabled
function M.toggle()
  enabled = not enabled
  if not enabled then
    M.clear()
  end
  return enabled
end

---@param event vim.api.keyset.create_autocmd.callback_args
local function clear_on_move(event)
  if not cursor_on_reference(event.buf) then
    M.clear(event.buf)
  end
end

---@param event vim.api.keyset.create_autocmd.callback_args
local function clear_on_event(event) M.clear(event.buf) end

---@public
function M.setup()
  local group = vim.api.nvim_create_augroup('cursor_symbol', { clear = true })
  vim.api.nvim_create_autocmd('CursorHold', { group = group, callback = M.highlight })
  vim.api.nvim_create_autocmd('CursorMoved', { group = group, callback = clear_on_move })
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufLeave' }, { group = group, callback = clear_on_event })
  vim.api.nvim_create_user_command('CursorSymbolToggle', M.toggle, {})
end

return M
