local default_handler = vim.lsp.handlers['textDocument/inlayHint']
local max_length = 20

--- replace angle-bracket contents with "..." and remove namespaces
--- std::vector<int> -> vector<int> -> vector<...>
--- @param str string
local function shorten_label(str)
  local result = str
  if result:len() > max_length then
    local current_length = result:len()
    local prefix = result:match('^(: )')
    result = result:gsub('^.*::', '')
    if prefix and result:len() < current_length then
      result = prefix .. result
    end
  end
  if result:len() > max_length then
    result = result:gsub('<.*', '<...>')
  end
  return result
end

---@param err? lsp.ResponseError
---@param result lsp.InlayHint[]?
---@param ctx lsp.HandlerContext
local function on_inlayhint(err, result, ctx)
  if not err and result then
    vim.iter(result):each(
      ---@param hint lsp.InlayHint
      function(hint)
        if type(hint.label) == 'string' then
          ---@diagnostic disable-next-line: param-type-mismatch
          hint.label = shorten_label(hint.label)
        elseif type(hint.label) == 'table' then
          vim.iter(hint.label):each(function(part) part.value = shorten_label(part.value) end)
        end
      end
    )
  end
  return default_handler(err, result, ctx)
end

return {
  cmd = {
    'clangd',
    -- '/usr/local/bin/clangd',
    '--background-index',
    '--background-index-priority=background',
    '--all-scopes-completion',
    '--pch-storage=memory',
    '--completion-style=detailed',
    '--clang-tidy',
    '--enable-config',
    '--header-insertion=iwyu',
    '--all-scopes-completion',
    '-j',
    '2',
  },
  handlers = {
    ['textDocument/inlayHint'] = on_inlayhint,
  },
}
