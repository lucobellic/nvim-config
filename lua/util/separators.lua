local M = {}

local ns_id = vim.api.nvim_create_namespace('function_class_separators')

M.enabled = true
M.query_cache = {}

M.common_node_types = {
  ['*'] = {
    'function_definition',
    'function_declaration',
    'class_definition',
    'class_declaration',
    'class_specifier',
    'method_definition',
    'struct_specifier',
  },
  lua = {
    'function_declaration',
  },
}

--- Get or create a treesitter query for separator nodes in the given language.
--- This function validates each common node type against the language grammar
--- and builds a query containing only valid node types. Results are cached per language.
--- Uses language-specific node types if available, otherwise falls back to wildcard '*'.
---@param lang string The treesitter language name (e.g., 'lua', 'python', 'cpp')
---@return vim.treesitter.Query? query The compiled query object, or nil if no valid patterns exist
local function get_or_create_query(lang)
  -- Check cache first
  local query = M.query_cache[lang]

  if query ~= nil then
    return query
  end

  -- Try to get a predefined 'separators' query
  local ok
  ok, query = pcall(vim.treesitter.query.get, lang, 'separators')

  if not ok or not query then
    -- Get node types for this language (language-specific or wildcard)
    local node_types = M.common_node_types[lang] or M.common_node_types['*']

    if not node_types then
      M.query_cache[lang] = false
      return nil
    end

    -- Filter node types to only include those valid for this language
    local valid_patterns = {}
    for _, node_type in ipairs(node_types) do
      local test_query = string.format('(%s) @test', node_type)
      local is_valid = pcall(vim.treesitter.query.parse, lang, test_query)
      if is_valid then
        table.insert(valid_patterns, string.format('(%s) @separator', node_type))
      end
    end

    -- Only create query if we have valid patterns
    if #valid_patterns > 0 then
      ok, query = pcall(vim.treesitter.query.parse, lang, table.concat(valid_patterns, '\n'))
      if not ok then
        query = false
      end
    else
      query = false
    end
  end

  -- Cache the result (false if no valid query to avoid re-computing)
  M.query_cache[lang] = query

  return query ~= false and query or nil
end

local function add_separators(bufnr)
  bufnr = bufnr or 0
  if not M.enabled then
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return
  end

  local tree = parser:parse()[1]
  if not tree then
    return
  end

  local lang = parser:lang()
  local query = get_or_create_query(lang)

  if not query then
    return
  end

  vim
    .iter(query:iter_captures(tree:root(), bufnr))
    :filter(function(id, node) return query.captures[id] == 'separator' and node:range() > 0 end)
    :each(function(_, node)
      local row = node:range()
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, 0, {
        virt_lines = { { { string.rep('_', vim.api.nvim_win_get_width(0)), 'Comment' } } },
        virt_lines_above = true,
      })
    end)
end

function M.toggle()
  M.enabled = not M.enabled
  if M.enabled then
    add_separators()
  else
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  end
  vim.notify(
    string.format('Function/class separators %s', M.enabled and 'enabled' or 'disabled'),
    M.enabled and vim.log.levels.INFO or vim.log.levels.WARN,
    { title = 'Separators' }
  )
end

function M.setup(opts)
  opts = opts or {}
  M.enabled = opts.enabled ~= false

  local group = vim.api.nvim_create_augroup('FunctionClassSeparators', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'WinResized' }, {
    group = group,
    callback = function(ev) add_separators(ev.buf) end,
  })

  vim.api.nvim_create_user_command('ToggleSeparators', M.toggle, { desc = 'Toggle Function Separators' })
  vim.keymap.set('n', '<leader>uj', M.toggle, { desc = 'Toggle Function Separators', repeatable = true })
end

return M
