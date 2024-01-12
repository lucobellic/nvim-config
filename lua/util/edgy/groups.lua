-- Custom scripts to group edgebar by filetype
-- Limitations:
-- - TODO

local Config = require('edgy.config')
local Util = require('edgy.util')

-- Define groups of edgebar views by filetype
---@class Edgy.Group
---@field title string
---@field pos Edgy.Pos
---@field filetypes string[]

---@class Edgy.Group.Opts
---@field groups Edgy.Group[]

---@class Edgy.Group: Edgy.Group.Opts
---@field current_group_index table<string, number> @Index of the current group for each position
local M = {}
M.__index = M

---@param opts Edgy.Group.Opts
function M.new(opts)
  local self = setmetatable(opts, M)
  self.groups = opts.groups
  self.current_group_index = { bottom = 1, left = 1, right = 1, top = 1 }
  return self
end

-- Filter views by filetype
---@param views Edgy.View[]
---@param filetypes string[]
---@return Edgy.View[]
local function filter_by_filetypes(views, filetypes)
  return vim.tbl_filter(function(view) return vim.tbl_contains(filetypes, view.ft) end, views)
end

---@param Edgy.View
local function sync_open_pinned(view)
  view.opening = true
  if type(view.open) == 'function' then
    Util.try(view.open)
  elseif type(view.open) == 'string' then
    Util.try(function() vim.cmd(view.open) end)
  else
    Util.error('View is pinned and has no open function')
  end
  view.opening = false
end

-- Close or hide edgebar views for the given position and filetype
---@param pos Edgy.Pos
---@param filetypes string[]
---@param hide boolean|nil If true, hide the window instead of closing them
function M.close_edgebar_views_by_filetypes(pos, filetypes, hide)
  local edgebar = Config.layout[pos]
  if edgebar ~= nil then
    local views = filter_by_filetypes(edgebar.views, filetypes)
    for _, view in ipairs(views) do
      for _, win in ipairs(view.wins) do
        if hide ~= nil and hide then
          win:hide()
        else
          win:close()
        end
      end
    end
  end
end

-- Open edgebar views for the given position and filetype
---@param pos Edgy.Pos
---@param filetypes string[]
function M.open_edgebar_views_by_filetypes(pos, filetypes)
  local edgebar = Config.layout[pos]
  if edgebar ~= nil then
    local views = filter_by_filetypes(edgebar.views, filetypes)
    for _, view in ipairs(views) do
      -- view:open_pinned()
      sync_open_pinned(view)
    end
  end
end

-- TODO: add sync call
---@param pos Edgy.Pos
---@param offset number
function M:open_group(pos, offset)
  local group_index = self.current_group_index[pos]
  group_index = (self.current_group_index[pos] + offset - 1) % #self.groups + 1

  local current_group = self.groups[group_index]
  local other_groups = vim.tbl_filter(function(group) return group.title ~= current_group.title end, self.groups)
  local other_groups_filetypes = vim.tbl_map(function(group) return group.filetypes end, other_groups)

  -- local window = vim.api.nvim_get_current_win()
  -- local cursor = vim.api.nvim_win_get_cursor(window)
  self.open_edgebar_views_by_filetypes(pos, current_group.filetypes)
  self.close_edgebar_views_by_filetypes(pos, vim.tbl_flatten(other_groups_filetypes))
  -- Restore focus to the saved window
  -- TODO: handle the case where window was from an other group
  -- vim.api.nvim_win_set_cursor(window, cursor)

  self.current_group_index[pos] = group_index
end

return M
