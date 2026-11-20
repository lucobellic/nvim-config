---@alias DiffRibbon.Kind 'add'|'delete'|'change'

---@class DiffRibbon.Hunk
---@field kind DiffRibbon.Kind
---@field left_start integer
---@field left_count integer
---@field right_start integer
---@field right_count integer

local M = {}

-- Flags mirror 'diffopt' so the ribbons agree with the highlights Neovim draws.
local flag_options = {
  ['indent-heuristic'] = { 'indent_heuristic', true },
  iwhite = { 'ignore_whitespace_change', true },
  iwhiteall = { 'ignore_whitespace', true },
  iwhiteeol = { 'ignore_whitespace_change_at_eol', true },
  iblank = { 'ignore_blank_lines', true },
}

---@return table
local function diff_options()
  local options = { result_type = 'indices' }
  vim.iter(vim.split(vim.o.diffopt, ',', { trimempty = true })):each(function(item)
    local key, value = item:match('^(%w+):(.+)$')
    if key == 'algorithm' then
      options.algorithm = value
    elseif key == 'linematch' then
      options.linematch = tonumber(value)
    elseif flag_options[item] then
      options[flag_options[item][1]] = flag_options[item][2]
    end
  end)
  return options
end

---@param buffer integer
---@return string
local function buffer_text(buffer) return table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), '\n') .. '\n' end

---@param left_count integer
---@param right_count integer
---@return DiffRibbon.Kind
local function kind(left_count, right_count)
  if left_count == 0 then
    return 'add'
  elseif right_count == 0 then
    return 'delete'
  end
  return 'change'
end

---@param left_buffer integer
---@param right_buffer integer
---@return DiffRibbon.Hunk[]
function M.compute(left_buffer, right_buffer)
  local indices = vim.text.diff(buffer_text(left_buffer), buffer_text(right_buffer), diff_options()) --[[@as integer[][] ]]
  return vim
    .iter(indices)
    :map(
      function(index)
        return {
          kind = kind(index[2], index[4]),
          left_start = index[1],
          left_count = index[2],
          right_start = index[3],
          right_count = index[4],
        }
      end
    )
    :totable()
end

return M
