local M = {}

-- True while this plugin is the reason 'filler' is missing from 'diffopt'.
local removed = false

---@return string[]
local function items() return vim.split(vim.o.diffopt, ',', { trimempty = true }) end

--- Drop filler lines so each side keeps its real shape and the ribbons can bend.
function M.remove()
  local current = items()
  if vim.list_contains(current, 'filler') then
    vim.o.diffopt = table.concat(vim.tbl_filter(function(item) return item ~= 'filler' end, current), ',')
    removed = true
  end
end

function M.restore()
  local current = items()
  if removed and not vim.list_contains(current, 'filler') then
    table.insert(current, 'filler')
    vim.o.diffopt = table.concat(current, ',')
  end
  removed = false
end

return M
