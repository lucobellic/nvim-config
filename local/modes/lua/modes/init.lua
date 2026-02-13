--- Module for managing cursor line highlights in insert mode
---@class ModesModule
---@field private config ModesConfig Plugin configuration
---@field private highlights table Mode-specific highlight definitions
---@field private original_highlights table Saved original highlights
---@field private original_cursorlineopt string Saved cursorlineopt setting
local M = {
  original_highlights = {},
  original_cursorlineopt = vim.opt.cursorlineopt:get(),
}

---@class ModesConfig
---@field highlights? table Custom highlight definitions for different modes

---@type ModesConfig
local defaults = {
  highlights = {
    insert = {
      CursorLine = { bg = '#1B3320' },
      CursorLineNr = { bg = '#1B3320' },
      CursorLineFold = { bg = '#1B3320' },
    },
    visual = {
      CursorLine = { bg = '#1b3a5a' },
      CursorLineNr = { bg = '#1b3a5a' },
      CursorLineFold = { bg = '#1b3a5a' },
    },
  },
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
    { pattern = 'n:i', highlights = M.config.highlights.insert },
    { pattern = 'n:V', highlights = M.config.highlights.visual },
    { pattern = 'n:no*', highlights = M.config.highlights.visual },
  }
  vim.iter(mode_changed_commands):each(function(cmd)
    vim.api.nvim_create_autocmd('ModeChanged', {
      pattern = cmd.pattern,
      callback = function() M.apply_highlights(cmd.highlights) end,
    })
  end)
end

--- Setup the modes plugin with the given configuration
---@param opts? ModesConfig User configuration (merged with defaults)
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', defaults, opts or {})

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

return M
