local M = {}

local ns_id = vim.api.nvim_create_namespace('function_class_separators')

M.enabled = true

M.common_node_types = {
  'function_definition',
  'function_declaration',
  'class_definition',
  'class_declaration',
  'class_specifier',
  'method_definition',
  'struct_specifier',
}

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

  local ok, query = pcall(vim.treesitter.query.get, lang, 'separators')

  if not ok or not query then
    local patterns = vim.tbl_map(function(type) return string.format('(%s) @separator', type) end, M.common_node_types)

    ok, query = pcall(vim.treesitter.query.parse, lang, table.concat(patterns, '\n'))
    if not ok then
      return
    end
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
  vim.notify(string.format('Function/class separators %s', M.enabled and 'enabled' or 'disabled'), vim.log.levels.INFO)
end

function M.setup(opts)
  opts = opts or {}
  M.enabled = opts.enabled ~= false

  local group = vim.api.nvim_create_augroup('FunctionClassSeparators', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'WinResized' }, {
    group = group,
    callback = function(ev) add_separators(ev.buf) end,
  })

  vim.api.nvim_create_user_command('SeparatorsToggle', M.toggle, { desc = 'Toggle function/class separators' })
end

return M
