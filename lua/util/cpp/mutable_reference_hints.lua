--- Mutable reference virtual text hints for clangd
--- Shows a virtual `&` symbol before variables marked as mutable references
--- Only displays when native LSP inlay hints are disabled
---
---@class MutableReferenceHints
local M = {}

-- Create namespace for extmarks
M.namespace = vim.api.nvim_create_namespace('mutable_reference_hints')

-- State tracking
---@class MutableRefState
---@field enabled boolean Global enabled state (inverse of inlay hints)
---@field buffers table<integer, BufferState> Per-buffer state
M.state = {
  enabled = true, -- Start enabled (assuming inlay hints are off by default)
  buffers = {},
}

---@class BufferState
---@field extmarks table<integer, boolean> Extmark IDs for cleanup
---@field client_id integer? Associated LSP client
---@field tokens table? Cached semantic tokens

-- Semantic token legend indices (these need to be determined from the server)
-- We'll dynamically look these up from the client's semantic token legend
local token_cache = {}

--- Get semantic token legend from client
---@param client_id integer
---@return table? legend
local function get_semantic_token_legend(client_id)
  if token_cache[client_id] then
    return token_cache[client_id]
  end

  local client = vim.lsp.get_client_by_id(client_id)
  if not client then
    return nil
  end

  local legend = vim.tbl_get(client, 'server_capabilities', 'semanticTokensProvider', 'legend')
  if legend then
    token_cache[client_id] = legend
  end

  return legend
end

--- Check if token has usedAsMutableReference modifier
---@param modifiers integer Bitfield of token modifiers
---@param legend table Semantic token legend
---@return boolean
local function has_mutable_ref_modifier(modifiers, legend)
  if not legend or not legend.tokenModifiers then
    return false
  end

  -- Find the index of 'usedAsMutableReference' in the modifiers list
  local modifier_index = nil
  for i, mod in ipairs(legend.tokenModifiers) do
    if mod == 'usedAsMutableReference' then
      modifier_index = i - 1 -- 0-indexed
      break
    end
  end

  if not modifier_index then
    return false
  end

  -- Check if the bit is set
  return bit.band(modifiers, bit.lshift(1, modifier_index)) ~= 0
end

--- Decode semantic tokens and place extmarks for mutable references
---@param bufnr integer
---@param data integer[] Semantic token data
---@param client_id integer
local function process_semantic_tokens(bufnr, data, client_id)
  if not M.state.enabled then
    return
  end

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local legend = get_semantic_token_legend(client_id)
  if not legend then
    return
  end

  -- Clear existing extmarks for this buffer
  M.clear_buffer(bufnr)

  -- Initialize buffer state
  if not M.state.buffers[bufnr] then
    M.state.buffers[bufnr] = {
      extmarks = {},
      client_id = client_id,
    }
  end

  local buf_state = M.state.buffers[bufnr]

  -- Decode delta-encoded semantic tokens
  -- Format: [deltaLine, deltaCol, length, tokenType, tokenModifiers, ...]
  local line = 0
  local col = 0

  for i = 1, #data, 5 do
    local delta_line = data[i]
    local delta_col = data[i + 1]
    -- local length = data[i + 2] -- Unused, but part of semantic token format
    -- local token_type = data[i + 3] -- Unused, but part of semantic token format
    local token_modifiers = data[i + 4]

    -- Update position
    if delta_line > 0 then
      line = line + delta_line
      col = delta_col
    else
      col = col + delta_col
    end

    -- Check if this token has the mutable reference modifier
    if has_mutable_ref_modifier(token_modifiers, legend) then
      -- Place extmark with '&' virtual text
      ---@diagnostic disable-next-line: missing-fields
      local ok, extmark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, M.namespace, line, col, {
        virt_text = { { '&', 'LspInlayHint' } },
        virt_text_pos = 'inline',
        priority = 100,
        right_gravity = false,
        hl_mode = 'combine',
      })

      if ok then
        buf_state.extmarks[extmark_id] = true
      end
    end
  end
end

--- Clear extmarks for a specific buffer
---@param bufnr integer
function M.clear_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    M.state.buffers[bufnr] = nil
    return
  end

  -- Clear all extmarks in this buffer
  pcall(vim.api.nvim_buf_clear_namespace, bufnr, M.namespace, 0, -1)

  -- Clear buffer state
  if M.state.buffers[bufnr] then
    M.state.buffers[bufnr].extmarks = {}
  end
end

--- Refresh semantic tokens for a buffer
---@param bufnr integer
function M.refresh_buffer(bufnr)
  if not M.state.enabled then
    M.clear_buffer(bufnr)
    return
  end

  local buf_state = M.state.buffers[bufnr]
  if not buf_state or not buf_state.client_id then
    return
  end

  local client = vim.lsp.get_client_by_id(buf_state.client_id)
  if not client then
    return
  end

  -- Request semantic tokens
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
  }

  ---@diagnostic disable-next-line: invisible
  client.request('textDocument/semanticTokens/full', params, function(err, result)
    if err or not result or not result.data then
      return
    end

    if buf_state.client_id then
      process_semantic_tokens(bufnr, result.data, buf_state.client_id)
    end
  end, bufnr)
end

--- Enable or disable mutable reference hints globally
---@param enable boolean
function M.set_enabled(enable)
  M.state.enabled = enable

  if enable then
    -- Refresh all active buffers
    for bufnr, _ in pairs(M.state.buffers) do
      M.refresh_buffer(bufnr)
    end
  else
    -- Clear all buffers
    for bufnr, _ in pairs(M.state.buffers) do
      M.clear_buffer(bufnr)
    end
  end
end

--- Toggle based on inlay hint state (inverse relationship)
function M.sync_with_inlay_hints()
  local inlay_hints_enabled = vim.lsp.inlay_hint.is_enabled()
  M.set_enabled(not inlay_hints_enabled)
end

--- Setup function to be called on LspAttach for clangd
---@param client vim.lsp.Client
---@param bufnr integer
function M.setup_buffer(client, bufnr)
  -- Only setup for clangd
  if client.name ~= 'clangd' then
    return
  end

  -- Check if client supports semantic tokens
  if not vim.tbl_get(client, 'server_capabilities', 'semanticTokensProvider') then
    return
  end

  -- Initialize buffer state
  M.state.buffers[bufnr] = {
    extmarks = {},
    client_id = client.id,
  }

  -- Set initial state based on inlay hints
  M.sync_with_inlay_hints()

  -- Request initial semantic tokens if enabled
  if M.state.enabled then
    vim.defer_fn(function() M.refresh_buffer(bufnr) end, 100)
  end
end

--- Cleanup function for buffer
---@param bufnr integer
function M.cleanup_buffer(bufnr)
  M.clear_buffer(bufnr)
  M.state.buffers[bufnr] = nil
end

--- Setup autocmds for lifecycle management
---@diagnostic disable-next-line: codespell
function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup('MutableReferenceHints', { clear = true })

  -- Setup on LspAttach
  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        M.setup_buffer(client, args.buf)
      end
    end,
  })

  -- Cleanup on LspDetach
  vim.api.nvim_create_autocmd('LspDetach', {
    group = group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.name == 'clangd' then
        M.cleanup_buffer(args.buf)
      end
    end,
  })

  -- Cleanup on buffer delete
  vim.api.nvim_create_autocmd('BufDelete', {
    group = group,
    callback = function(args) M.cleanup_buffer(args.buf) end,
  })

  -- Refresh on text changes (debounced)
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group,
    callback = function(args)
      if not M.state.enabled then
        return
      end
      if M.state.buffers[args.buf] then
        vim.defer_fn(function() M.refresh_buffer(args.buf) end, 500)
      end
    end,
  })
end

--- Handle semantic tokens to display mutable reference hints
---@param err? lsp.ResponseError
---@param result lsp.SemanticTokens?
---@param ctx lsp.HandlerContext
function M.on_semantic_tokens(err, result, ctx)
  if err or not result or not result.data then
    return
  end

  local bufnr = ctx.bufnr
  local client_id = ctx.client_id

  if not bufnr then
    return
  end

  -- Process semantic tokens for mutable references
  M.state.buffers[bufnr] = M.state.buffers[bufnr] or {
    extmarks = {},
    client_id = client_id,
  }

  -- Decode and process tokens
  vim.schedule(function()
    if M.state.enabled then
      M.clear_buffer(bufnr)

      local client = vim.lsp.get_client_by_id(client_id)
      if not client then
        return
      end

      local legend = vim.tbl_get(client, 'server_capabilities', 'semanticTokensProvider', 'legend')
      if not legend then
        return
      end

      -- Find modifier index for 'usedAsMutableReference'
      local modifier_index = vim
        .iter(ipairs(legend.tokenModifiers))
        :filter(function(_, mod) return mod == 'usedAsMutableReference' end)
        :map(function(i, _) return i - 1 end)
        :nth(1)

      if not modifier_index then
        return
      end

      -- Decode semantic tokens
      local data = result.data
      local line = 0
      local col = 0
      local buf_state = M.state.buffers[bufnr]

      for i = 1, #data, 5 do
        local delta_line = data[i]
        local delta_col = data[i + 1]
        local token_modifiers = data[i + 4]

        -- Update position
        if delta_line > 0 then
          line = line + delta_line
          col = delta_col
        else
          col = col + delta_col
        end

        -- Check if this token has the mutable reference modifier
        if bit.band(token_modifiers, bit.lshift(1, modifier_index)) ~= 0 then
          ---@diagnostic disable-next-line: missing-fields
          local ok, extmark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, M.namespace, line, col, {
            virt_text = { { '&', 'LspInlayHint' } },
            virt_text_pos = 'inline',
            priority = 100,
            right_gravity = false,
            hl_mode = 'combine',
          })

          if ok and buf_state then
            buf_state.extmarks[extmark_id] = true
          end
        end
      end
    end
  end)
end

--- Initialize the module
function M.setup()
  M.setup_autocmds()
  M.sync_with_inlay_hints()
end

return M
