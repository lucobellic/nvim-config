---@type lsp.Handler
local default_inlay_hint_handler = vim.lsp.handlers['textDocument/inlayHint']
local max_length = 20

-- Load mutable reference hints module
local mutable_ref_hints = require('util.cpp.mutable_reference_hints')

--- replace angle-bracket contents with "..." and remove namespaces
--- std::vector<int> -> vector<...>
--- const std::optional<std::vector<int>> -> const optional<vector<int>>
--- @param str string
local function shorten_label(str)
  local result = str
  if result:len() > max_length then
    local current_length = result:len()
    local prefix = result:match('^(: )')

    -- Remove namespaces from both outer type and generic parameters
    -- Process each segment between angle brackets separately
    result = result:gsub('([%w_]+)::([%w_<>:]+)', function(_, rest)
      -- Recursively strip namespaces from the rest
      return rest:gsub('([%w_]+)::', '')
    end)

    if prefix and not result:match('^(: )') and result:len() < current_length then
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
  return default_inlay_hint_handler(err, result, ctx)
end

-- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
local function switch_source_header(bufnr, client)
  local method_name = 'textDocument/switchSourceHeader'
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify('corresponding file cannot be determined')
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

local function symbol_info(bufnr, client)
  local method_name = 'textDocument/symbolInfo'
  ---@diagnostic disable-next-line:param-type-mismatch
  if not client or not client:supports_method(method_name) then
    return vim.notify('Clangd client not found', vim.log.levels.ERROR)
  end
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request(method_name, params, function(err, res)
    if err or #res == 0 then
      -- Clangd always returns an error, there is no reason to parse it
      return
    end
    local container = string.format('container: %s', res[1].containerName) ---@type string
    local name = string.format('name: %s', res[1].name) ---@type string
    vim.lsp.util.open_floating_preview({ name, container }, '', {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = 'Symbol Info',
    })
  end, bufnr)
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
    ['textDocument/semanticTokens/full'] = mutable_ref_hints.on_semantic_tokens,
  },
  on_attach = function(client, bufnr)
    mutable_ref_hints.setup_buffer(client, bufnr)
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'LspClangdSwitchSourceHeader',
      function() switch_source_header(bufnr, client) end,
      { desc = 'Switch between source/header' }
    )

    vim.api.nvim_buf_create_user_command(
      bufnr,
      'LspClangdShowSymbolInfo',
      function() symbol_info(bufnr, client) end,
      { desc = 'Show symbol info' }
    )
  end,
}
