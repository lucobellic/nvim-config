-- Module for managing cursor line highlights in insert mode
local M = {
  highlights = {
    insert = {
      CursorLine = { bg = '#2d4a2f' },
      CursorLineNr = { bg = '#2d4a2f' },
      CursorLineFold = { bg = '#2d4a2f' },
    },
    visual = {
      CursorLine = { bg = '#1b3a5a' },
      CursorLineNr = { bg = '#1b3a5a' },
      CursorLineFold = { bg = '#1b3a5a' },
    },
  },
  original_highlights = {},
  original_cursorlineopt = vim.opt.cursorlineopt:get(),
}

--- Store original highlights
function M.save_highlights()
  M.original_highlights = vim
    .iter({ 'CursorLine', 'CursorLineNr', 'CursorLineFold' })
    :map(function(group) return { group = group, hl = vim.api.nvim_get_hl(0, { name = group, link = true }) } end)
    :totable()
end

--- Apply insert mode highlights
function M.apply_highlights(highlights)
  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end
end

--- Clean highlight table by removing metadata fields
---@param hl table Highlight table from nvim_get_hl
---@return table Cleaned highlight table
function M.clean_highlight(hl)
  local cleaned = vim.tbl_extend('force', {}, hl)
  cleaned.default = nil
  return cleaned
end

--- Restore original highlights
function M.restore_highlights()
  vim.iter(M.original_highlights):each(function(highlight)
    local cleaned_hl = M.clean_highlight(highlight.hl)
    vim.api.nvim_set_hl(0, highlight.group, cleaned_hl)
  end)
end

function M.create_mode_changed_highlight_autocmd()
  local mode_changed_commands = {
    { pattern = '*:i', highlights = M.highlights.insert },
    { pattern = '*:V', highlights = M.highlights.visual },
    { pattern = '*:no*', highlights = M.highlights.visual },
  }
  vim.iter(mode_changed_commands):each(function(cmd)
    vim.api.nvim_create_autocmd('ModeChanged', {
      pattern = cmd.pattern,
      callback = function() M.apply_highlights(cmd.highlights) end,
    })
  end)
end

--- Setup autocmds for cursor line highlights
function M.setup()
  local group = vim.api.nvim_create_augroup('CursorLineInsertMode', { clear = true })
  M.create_mode_changed_highlight_autocmd()

  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = '*:v',
    group = group,
    callback = function()
      M.original_cursorlineopt = vim.opt.cursorlineopt:get()
      vim.opt.cursorlineopt = 'line'
    end,
  })

  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = 'v:*',
    group = group,
    callback = function() vim.opt.cursorlineopt = M.original_cursorlineopt end,
  })

  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = '*:n',
    group = group,
    callback = M.restore_highlights,
  })

  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function() vim.schedule(M.save_highlights) end,
  })
end

-- Initialize on module load
M.setup()

return {
  'mvllow/modes.nvim',
  cond = false, -- Options and highlights are not respected
  version = '*',
  event = 'VeryLazy',
  opts = {
    ignore = function() return false end,
  },
}
