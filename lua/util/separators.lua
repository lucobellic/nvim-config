local M = {
  enabled = true,
  query_cache = {},
  common_node_types = {
    ['*'] = {
      'function_definition',
      'function_declaration',
      'class_definition',
      'class_declaration',
      'class_specifier',
      'method_definition',
      'struct_specifier',
      'template_declaration',
      'template_instantiation',
    },
    lua = {
      'function_declaration',
    },
  },

  --- Template-like node types that wrap function/class definitions.
  --- When a separator target node is a child of one of these, the separator
  --- is placed on the parent instead and the child is skipped.
  template_node_types = {
    'template_declaration',
    'template_instantiation',
    'decorated_definition',
  },
}

local ns_id = vim.api.nvim_create_namespace('function_class_separators')
local highlight = 'Separators'

--- Check whether a treesitter comment node ends on the line directly above `row`.
--- Walks siblings and previous nodes to find any comment that occupies `row - 1`.
---@param bufnr integer Buffer number
---@param root TSNode Root node of the tree
---@param row integer 0-indexed row of the target node
---@return boolean
local function has_comment_above(bufnr, root, row)
  if row == 0 then
    return false
  end

  local prev_row = row - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, prev_row, prev_row + 1, false)[1]
  if not line or line:match('^%s*$') then
    return false
  end

  -- Get the smallest node at the end of the previous line
  local col = #line - 1
  if col < 0 then
    return false
  end

  local node_at = root:named_descendant_for_range(prev_row, 0, prev_row, col)
  if not node_at then
    return false
  end

  -- Walk up from the detected node to check if it (or an ancestor ending on
  -- the same line) is a comment node.
  local cur = node_at
  while cur do
    local ntype = cur:type()
    if ntype == 'comment' or ntype:match('comment') then
      return true
    end
    local _, _, end_row = cur:range()
    -- Stop walking up once the ancestor extends beyond our line of interest
    if end_row ~= prev_row then
      break
    end
    cur = cur:parent()
  end

  return false
end

--- Check whether a node's parent is a template-like declaration.
---@param node TSNode
---@return boolean
local function has_template_parent(node)
  local parent = node:parent()
  if not parent then
    return false
  end

  local parent_type = parent:type()
  for _, tpl_type in ipairs(M.template_node_types) do
    if parent_type == tpl_type then
      return true
    end
  end
  return false
end

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

  local root = tree:root()

  vim
    .iter(query:iter_captures(root, bufnr))
    :filter(function(id, node)
      if query.captures[id] ~= 'separator' then
        return false
      end
      local row = node:range()
      -- Skip nodes at the very first line
      if row == 0 then
        return false
      end
      -- Skip nodes whose parent is a template-like declaration (the parent
      -- will get its own separator instead).
      if has_template_parent(node) then
        return false
      end
      -- Skip nodes that have a comment directly above them
      if has_comment_above(bufnr, root, row) then
        return false
      end
      return true
    end)
    :each(
      ---@param node TSNode
      function(_, node)
        local row = node:range()
        local line_above = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]

        -- Check if the line above is empty (whitespace only or nil)
        local is_empty = not line_above or line_above:match('^%s*$')

        if is_empty then
          vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, 0, {
            virt_text = { { string.rep('▄', vim.api.nvim_win_get_width(0)), highlight } },
            virt_text_pos = 'inline',
            invalidate = true,
          })
        else
          vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, 0, {
            virt_lines = { { { string.rep('▄', vim.api.nvim_win_get_width(0)), highlight } } },
            virt_lines_above = true,
            invalidate = true,
          })
        end
      end
    )
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

  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = function()
      local cursor_line_bg = vim.api.nvim_get_hl(0, { name = 'CursorLine' }).bg
      vim.api.nvim_set_hl(0, 'Separators', { fg = cursor_line_bg })
    end,
  })

  vim.api.nvim_create_user_command('ToggleSeparators', M.toggle, { desc = 'Toggle Function Separators' })
  vim.keymap.set('n', '<leader>uj', M.toggle, { desc = 'Toggle Function Separators', repeatable = true })
end

return M
