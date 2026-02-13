--- Autocmd setup for inlay hints.
---@class InlayHintsAutocmdsModule
local M = {}

local state = require('inlay-hints-custom.state')
local utils = require('inlay-hints-custom.utils')

--- Set up autocmds for inlay hints.
function M.setup_autocmds()
  local augroup = vim.api.nvim_create_augroup('InlayHintsCustom', { clear = true })

  -- Refresh hints when buffer content changes
  vim.api.nvim_create_autocmd('LspNotify', {
    group = augroup,
    callback = function(args)
      local bufnr = args.buf
      local method = args.data.method
      if method ~= 'textDocument/didChange' and method ~= 'textDocument/didOpen' then
        return
      end
      local bufstate = state.get_buf_state(bufnr)
      if bufstate and bufstate.enabled then
        utils.refresh(bufnr, args.data.client_id)
      end
    end,
    desc = 'Refresh inlay hints on buffer change',
  })

  -- Attach buffer tracking when LSP attaches
  vim.api.nvim_create_autocmd('LspAttach', {
    group = augroup,
    callback = function(args)
      local bufnr = args.buf
      vim.api.nvim_buf_attach(bufnr, false, {
        on_reload = function(_, cb_bufnr)
          utils.clear(cb_bufnr)
          local bufstate = state.get_buf_state(cb_bufnr)
          if bufstate and bufstate.enabled then
            bufstate.applied = {}
            utils.refresh(cb_bufnr)
          end
        end,
        on_detach = function(_, cb_bufnr)
          utils.disable(cb_bufnr)
          state.clear_buf_state(cb_bufnr)
        end,
      })
    end,
    desc = 'Attach inlay hint tracking to buffer',
  })

  -- Clean up hints when LSP detaches
  vim.api.nvim_create_autocmd('LspDetach', {
    group = augroup,
    callback = function(args)
      local bufnr = args.buf
      local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/inlayHint' })
      if not vim.iter(clients):any(function(c) return c.id ~= args.data.client_id end) then
        utils.disable(bufnr)
      end
    end,
    desc = 'Clean up inlay hints on LSP detach',
  })
end

return M
