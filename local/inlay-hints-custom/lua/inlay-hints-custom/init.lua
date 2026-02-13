--- Custom inlay hints display plugin for Neovim.
--- Overrides `vim.lsp.inlay_hint` to allow customizing how inlay hints are rendered.
---
--- By default, uses the native Neovim inline behavior. When `format_hint` is provided,
--- each hint is passed through it before rendering, allowing full control over label,
--- highlight, position, and visibility.
---
--- Usage:
--- ```lua
--- require('inlay-hints-custom').setup({
---   format_hint = function(hint, bufnr, client_id)
---     -- Add icons based on hint kind
---     if hint.kind == 1 then -- Type
---       hint.label = ' ' .. hint.label
---     elseif hint.kind == 2 then -- Parameter
---       hint.label = '󰏪 ' .. hint.label
---     end
---     return hint -- return nil to hide this hint
---   end,
--- })
--- ```
---
---@class InlayHintsCustomModule
---@field private config InlayHintsCustomConfig Plugin configuration
local M = {}

-- Import submodules
local autocmds = require('inlay-hints-custom.autocmds')
local config = require('inlay-hints-custom.config')
local handlers = require('inlay-hints-custom.handlers')
local render = require('inlay-hints-custom.render')
local state = require('inlay-hints-custom.state')
local utils = require('inlay-hints-custom.utils')

-- Export kind constant for convenience
M.kind = config.kind

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

--- Check whether inlay hints are enabled.
---@public
---@param filter? { bufnr?: integer }
---@return boolean
function M.is_enabled(filter)
  filter = filter or {}
  if filter.bufnr == nil then
    return state.globalstate.enabled
  end
  local bufstate = state.get_buf_state(vim._resolve_bufnr(filter.bufnr))
  return bufstate and bufstate.enabled or false
end

--- Enable, disable, or toggle inlay hints.
---@public
---@param enable? boolean true to enable, false to disable (nil = enable)
---@param filter? { bufnr?: integer }
function M.enable(enable, filter)
  enable = enable == nil or enable
  filter = filter or {}

  if filter.bufnr == nil then
    -- Global enable/disable
    state.globalstate.enabled = enable
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        if enable then
          utils.enable(bufnr)
        else
          utils.disable(bufnr)
        end
      else
        state.clear_buf_state(bufnr)
      end
    end
  else
    -- Buffer-specific enable/disable
    if enable then
      utils.enable(filter.bufnr)
    else
      utils.disable(filter.bufnr)
    end
  end
end

--- Setup the plugin. Replaces `vim.lsp.inlay_hint` with this module.
---@public
---@param opts? InlayHintsCustomConfig
function M.setup(opts)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend('force', config.defaults, opts or {})

  -- Install LSP handlers
  vim.lsp.handlers['textDocument/inlayHint'] = handlers.on_inlayhint
  vim.lsp.handlers['workspace/inlayHint/refresh'] = handlers.on_refresh

  -- Set up decoration provider and autocmds
  render.create_decoration_provider(M.config)
  autocmds.setup_autocmds()

  -- Replace the native module so vim.lsp.inlay_hint.enable() etc. use ours
  vim.lsp.inlay_hint = M

  -- Enable if configured
  if M.config.enabled then
    M.enable(true)
  end
end

return M
