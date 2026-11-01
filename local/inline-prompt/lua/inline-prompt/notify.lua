---@param message string
---@param level integer
return function(message, level) vim.notify(message, level, { title = 'Inline prompt' }) end
