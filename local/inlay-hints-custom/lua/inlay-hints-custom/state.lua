--- Buffer state management for inlay hints.
---@class InlayHintsStateModule
local M = {}

---@class (private) InlayHintsGlobalState
---@field enabled boolean
---@type InlayHintsGlobalState
M.globalstate = { enabled = false }

---@class (private) InlayHintsBufState: InlayHintsGlobalState
---@field version? integer
---@field client_hints? table<integer, table<integer, lsp.InlayHint[]>>
---@field applied table<integer, integer>
---@type table<integer, InlayHintsBufState>
local bufstates = vim.defaulttable(function(_)
  return setmetatable({ applied = {} }, {
    __index = M.globalstate,
    __newindex = function(state, key, value)
      if M.globalstate[key] == value then
        rawset(state, key, nil)
      else
        rawset(state, key, value)
      end
    end,
  })
end)

M.namespace = vim.api.nvim_create_namespace('inlay-hints-custom')

--- Get global state.
---@return InlayHintsGlobalState
function M.get_global_state() return M.globalstate end

--- Get buffer state.
---@param bufnr integer
---@return InlayHintsBufState
function M.get_buf_state(bufnr) return bufstates[bufnr] end

--- Get raw buffer state (may be nil).
---@param bufnr integer
---@return InlayHintsBufState?
function M.get_raw_buf_state(bufnr) return rawget(bufstates, bufnr) end

--- Clear buffer state.
---@param bufnr integer
function M.clear_buf_state(bufnr)
  bufstates[bufnr] = nil
  bufstates[bufnr].enabled = false
end

--- Reset buffer state.
---@param bufnr integer
function M.reset_buf_state(bufnr)
  bufstates[bufnr] = nil
  bufstates[bufnr].enabled = true
end

return M
