--- Rendering logic for inlay hints using decoration provider.
---@class InlayHintsRenderModule
local M = {}

local state = require('inlay-hints-custom.state')
local util = require('vim.lsp.util')
local utils = require('inlay-hints-custom.utils')

--- Default format_hint function that reproduces native Neovim behavior.
---@param hint InlayHintItem
---@param bufnr integer
---@param client_id integer
---@return { label: string, highlight: string?, virt_text_pos: string?, col: integer? }?
function M.default_format_hint(hint, bufnr, client_id)
  return {
    label = hint.label,
    highlight = nil,
    virt_text_pos = nil,
    col = nil,
  }
end

--- Create and register the decoration provider for rendering hints.
---@param config InlayHintsCustomConfig
function M.create_decoration_provider(config)
  vim.api.nvim_set_decoration_provider(state.namespace, {
    on_win = function(_, _, bufnr, topline, botline)
      local bufstate = state.get_raw_buf_state(bufnr)
      if not bufstate or bufstate.version ~= util.buf_versions[bufnr] or not bufstate.client_hints then
        return
      end

      ---@type InlayHintsBufState
      local client_hints = bufstate.client_hints

      for lnum = topline, botline do
        if bufstate.applied[lnum] ~= bufstate.version then
          vim.api.nvim_buf_clear_namespace(bufnr, state.namespace, lnum, lnum + 1)

          if config.format_hint then
            -- Custom rendering via format_hint callback
            M.render_custom(bufnr, lnum, client_hints, config)
          else
            -- Default rendering (reproduces native Neovim behavior)
            M.render_default(bufnr, lnum, client_hints, config)
          end

          bufstate.applied[lnum] = bufstate.version
        end
      end
    end,
  })
end

--- Render hints with custom format_hint callback.
---@param bufnr integer
---@param lnum integer
---@param client_hints table<integer, table<integer, lsp.InlayHint[]>>
---@param config InlayHintsCustomConfig
function M.render_custom(bufnr, lnum, client_hints, config)
  -- Group hints by position and render position
  ---@type table<string, { hints: table[], virt_text_pos: string, col: integer }>
  local grouped = {}

  for client_id, lnum_hints in pairs(client_hints) do
    for _, hint in pairs(lnum_hints[lnum] or {}) do
      local item = utils.to_hint_item(hint)
      local display = config.format_hint(item, bufnr, client_id)
      if display then
        local text = display.label
        if hint.paddingLeft and not text:match('^%s') then
          text = ' ' .. text
        end
        if hint.paddingRight and not text:match('%s$') then
          text = text .. ' '
        end
        local hint_pos = display.virt_text_pos or config.virt_text_pos or 'inline'
        local col = display.col or hint.position.character
        local extmark_col = hint_pos == 'inline' and col or 0
        local key = string.format('%s:%d', hint_pos, extmark_col)

        if not grouped[key] then
          grouped[key] = { hints = {}, virt_text_pos = hint_pos, col = extmark_col }
        end
        table.insert(grouped[key].hints, { text = text, highlight = display.highlight or config.highlight })
      end
    end
  end

  -- Render each group with separators
  for _, group in pairs(grouped) do
    local virt_text = {}
    for i, hint_data in ipairs(group.hints) do
      if i > 1 and config.separator and config.separator ~= '' then
        table.insert(virt_text, { config.separator, config.highlight })
      end
      table.insert(virt_text, { hint_data.text, hint_data.highlight })
    end
    vim.api.nvim_buf_set_extmark(bufnr, state.namespace, lnum, group.col, {
      virt_text_pos = group.virt_text_pos,
      virt_text = virt_text,
      hl_mode = config.hl_mode,
      ephemeral = false,
      priority = config.priority,
    })
  end
end

--- Render hints with default behavior (uses default_format_hint).
---@param bufnr integer
---@param lnum integer
---@param client_hints table<integer, table<integer, lsp.InlayHint[]>>
---@param config InlayHintsCustomConfig
function M.render_default(bufnr, lnum, client_hints, config)
  -- Use default_format_hint to format hints
  local format_fn = M.default_format_hint

  -- Group hints by position and render position
  ---@type table<string, { hints: table[], virt_text_pos: string, col: integer }>
  local grouped = {}

  for client_id, lnum_hints in pairs(client_hints) do
    for _, hint in pairs(lnum_hints[lnum] or {}) do
      local item = utils.to_hint_item(hint)
      local display = format_fn(item, bufnr, client_id)
      if display then
        local text = display.label
        if hint.paddingLeft and not text:match('^%s') then
          text = ' ' .. text
        end
        if hint.paddingRight and not text:match('%s$') then
          text = text .. ' '
        end
        local hint_pos = display.virt_text_pos or config.virt_text_pos or 'inline'
        local col = display.col or hint.position.character
        local extmark_col = hint_pos == 'inline' and col or 0
        local key = string.format('%s:%d', hint_pos, extmark_col)

        if not grouped[key] then
          grouped[key] = { hints = {}, virt_text_pos = hint_pos, col = extmark_col }
        end
        table.insert(grouped[key].hints, { text = text, highlight = display.highlight or config.highlight })
      end
    end
  end

  -- Render each group with separators
  for _, group in pairs(grouped) do
    local virt_text = {}
    for i, hint_data in ipairs(group.hints) do
      if i > 1 and config.separator and config.separator ~= '' then
        table.insert(virt_text, { config.separator, config.highlight })
      end
      table.insert(virt_text, { hint_data.text, hint_data.highlight })
    end
    vim.api.nvim_buf_set_extmark(bufnr, state.namespace, lnum, group.col, {
      virt_text_pos = group.virt_text_pos,
      virt_text = virt_text,
      hl_mode = config.hl_mode,
      ephemeral = false,
      priority = config.priority,
    })
  end
end

return M
