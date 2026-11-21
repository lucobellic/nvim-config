---@alias DiffRibbon.Kind 'add'|'delete'|'change'

---@class DiffRibbon.Hunk
---@field kind DiffRibbon.Kind
---@field left_start integer
---@field left_count integer
---@field right_start integer
---@field right_count integer

local M = {}

-- Flags mirror 'diffopt' so the ribbons agree with the highlights Neovim draws.
---@type table<string, [string, boolean]>
local flag_options = {
  ['indent-heuristic'] = { 'indent_heuristic', true },
  iwhite = { 'ignore_whitespace_change', true },
  iwhiteall = { 'ignore_whitespace', true },
  iwhiteeol = { 'ignore_whitespace_change_at_eol', true },
  iblank = { 'ignore_blank_lines', true },
}

--- Options for `vim.text.diff`, read from the user's 'diffopt'.
---@return table
local function diff_options()
  ---@type table<string, string|number|boolean|nil>
  local options = { result_type = 'indices' }

  vim.iter(vim.split(vim.o.diffopt, ',', { trimempty = true })):each(
    ---@param item string
    function(item)
      -- Some items carry a value, such as `algorithm:patience`.
      local key, value = item:match('^(%w+):(.+)$')
      if key == 'algorithm' then
        options.algorithm = value
      elseif key == 'linematch' then
        options.linematch = tonumber(value)
      elseif flag_options[item] then
        options[flag_options[item][1]] = flag_options[item][2]
      end
    end
  )

  return options
end

--- Lines of a block in one buffer, numbered like Neovim does: an empty range starts at the line
--- just below its gap.
---@class DiffRibbon.Range
---@field start integer
---@field count integer

--- Ranges of one changed block, per buffer index.
---@alias DiffRibbon.Block table<integer, DiffRibbon.Range>

--- Range from a start and count of `vim.text.diff`, where an empty range starts above its gap.
---@param start integer
---@param count integer
---@return DiffRibbon.Range
local function range(start, count) return { start = count == 0 and start + 1 or start, count = count } end

---@param kind DiffRibbon.Kind
---@param left_start integer
---@param left_count integer
---@param right_start integer
---@param right_count integer
---@return DiffRibbon.Hunk
local function hunk(kind, left_start, left_count, right_start, right_count)
  return {
    kind = kind,
    left_start = left_start,
    left_count = left_count,
    right_start = right_start,
    right_count = right_count,
  }
end

--- Changes of every other buffer against the base one, per buffer index.
---@param texts string[]
---@param base integer
---@return table<integer, { base: DiffRibbon.Range, other: DiffRibbon.Range }[]>
local function changes_against(texts, base)
  local options = diff_options()
  local result = {}

  for index, text in ipairs(texts) do
    if index ~= base then
      local indices = vim.text.diff(texts[base], text, options) --[[@as integer[][] ]]
      result[index] = vim.tbl_map(
        function(item) return { base = range(item[1], item[2]), other = range(item[3], item[4]) } end,
        indices
      )
    end
  end

  return result
end

--- Spans of base lines where any buffer differs. Changes that overlap or touch share one span,
--- as Neovim merges them into one block.
---@param changes table<integer, { base: DiffRibbon.Range }[]>
---@return { first: integer, last: integer }[] First line and the line just after the span
local function spans(changes)
  local ranges = {}
  for _, list in pairs(changes) do
    vim.list_extend(ranges, vim.tbl_map(function(change) return change.base end, list))
  end
  table.sort(ranges, function(first, second) return first.start < second.start end)

  local result = {}
  for _, item in ipairs(ranges) do
    local span, last = result[#result], item.start + item.count
    if span and item.start <= span.last then
      span.last = math.max(span.last, last)
    else
      table.insert(result, { first = item.start, last = last })
    end
  end

  return result
end

--- Changed blocks over all buffers, the way Neovim builds them when more than two windows are
--- in diff mode: every buffer is compared with the base one, and overlapping changes merge.
---@param texts string[]
---@param base integer
---@return DiffRibbon.Block[]
local function blocks(texts, base)
  local changes = changes_against(texts, base)
  local result = vim.tbl_map(
    function(span) return { [base] = { start = span.first, count = span.last - span.first } } end,
    spans(changes)
  )

  -- Each buffer shifts from the base by the lines its earlier changes added or removed.
  for index, list in pairs(changes) do
    local shift, next_change = 0, 1
    for position, block in ipairs(result) do
      local first, last = block[base].start, block[base].start + block[base].count
      local start = first + shift
      while list[next_change] and list[next_change].base.start <= last do
        shift = shift + list[next_change].other.count - list[next_change].base.count
        next_change = next_change + 1
      end
      result[position][index] = { start = start, count = last + shift - start }
    end
  end

  return result
end

--- Whether two ranges hold the very same lines.
---@param lines string[][]
---@param first integer
---@param first_range DiffRibbon.Range
---@param second integer
---@param second_range DiffRibbon.Range
---@return boolean
local function same_lines(lines, first, first_range, second, second_range)
  if first_range.count ~= second_range.count then
    return false
  end

  for offset = 0, first_range.count - 1 do
    if lines[first][first_range.start + offset] ~= lines[second][second_range.start + offset] then
      return false
    end
  end

  return true
end

--- Lines at the top of a block that Neovim shows as changed in buffer `index`. The lines below
--- show as added, since no other buffer has a line that far into the block. When every other
--- buffer holding lines holds the same ones, the whole block shows as added.
---@param block DiffRibbon.Block
---@param index integer
---@param lines string[][]
---@return integer
local function changed_count(block, index, lines)
  local longest, same = 0, true
  for other, other_range in pairs(block) do
    if other ~= index and other_range.count > 0 then
      longest = math.max(longest, other_range.count)
      same = same and same_lines(lines, index, block[index], other, other_range)
    end
  end

  return same and 0 or math.min(block[index].count, longest)
end

--- Hunks between two buffers inside one block: their changed lines face each other, and the
--- added lines below narrow to a gap on the other side, matching the highlights Neovim draws.
---@param block DiffRibbon.Block
---@param left integer
---@param right integer
---@param lines string[][]
---@return DiffRibbon.Hunk[]
local function between(block, left, right, lines)
  local left_range, right_range = block[left], block[right]
  if left_range.count == 0 and right_range.count == 0 then
    return {}
  end

  local left_changed, right_changed = changed_count(block, left, lines), changed_count(block, right, lines)
  -- Both sides hold the same lines, added on both compared with another buffer.
  if left_changed == 0 and right_changed == 0 and left_range.count > 0 and right_range.count > 0 then
    return { hunk('add', left_range.start, left_range.count, right_range.start, right_range.count) }
  end

  local result = {}
  -- With three buffers, lines can show as changed against the third one while this side has
  -- none, so the changed band narrows to a gap there, numbered from the line above it.
  if left_changed > 0 or right_changed > 0 then
    local left_start = left_changed > 0 and left_range.start or left_range.start - 1
    local right_start = right_changed > 0 and right_range.start or right_range.start - 1
    table.insert(result, hunk('change', left_start, left_changed, right_start, right_changed))
  end

  local left_added, right_added = left_range.count - left_changed, right_range.count - right_changed
  if left_added > 0 then
    local gap = right_range.start + right_changed - 1
    table.insert(result, hunk('delete', left_range.start + left_changed, left_added, gap, 0))
  end
  if right_added > 0 then
    local gap = left_range.start + left_changed - 1
    table.insert(result, hunk('add', gap, 0, right_range.start + right_changed, right_added))
  end

  return result
end

--- Hunks between pairs of buffers, split the way Neovim highlights them.
---@param buffers integer[] Every buffer in diff mode, the first one being the one Neovim compares the others with
---@param links [integer, integer][] Indices in `buffers` of each pair, left one first
---@return DiffRibbon.Hunk[][] One list per pair
function M.compute(buffers, links)
  local lines = vim.tbl_map(function(buffer) return vim.api.nvim_buf_get_lines(buffer, 0, -1, false) end, buffers)
  -- Whole buffers as texts that end with a newline, like files on disk.
  local texts = vim.tbl_map(function(list) return table.concat(list, '\n') .. '\n' end, lines)
  local block_list = blocks(texts, 1)

  return vim.tbl_map(function(link)
    return vim
      .iter(block_list)
      :fold({}, function(list, block) return vim.list_extend(list, between(block, link[1], link[2], lines)) end)
  end, links)
end

return M
