---@class InclineHandler
---@field filetype string|nil optional single filetype shortcut
local Handler = {}

---@param o table
---@return InclineHandler
function Handler:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end

---@param props table incline props { buf, win, focused }
---@return boolean
function Handler:match(props)
  if self.filetype then
    return vim.bo[props.buf].filetype == self.filetype
  end
  return false
end

---@param props table
---@return table incline render result
function Handler:render(props)
  local title = ' ' .. (self.filetype or '?') .. ' '
  return { { title, group = props.focused and 'FloatTitle' or 'Title' } }
end

return Handler
