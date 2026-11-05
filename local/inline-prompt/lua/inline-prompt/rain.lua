local config = require('inline-prompt.config')

---@class InlinePrompt.Run
---@field row integer
---@field col integer
---@field parts string[] Glyphs and gaps picked once, then only reordered
---@field inline? boolean Insert the text instead of covering the buffer text

---@class InlinePrompt.Layout
---@field tick integer
---@field range InlinePrompt.Range
---@field runs InlinePrompt.Run[]

---@class InlinePrompt.Shuffle
local M = {}

-- The same katakana in full width, two cells wide.
local WIDE_GLYPHS =
  vim.fn.split('ハヒシツウーナミモニサワオリホマエキムテケメカユラセネスタヌ', '\\zs')

-- Glyphs seen in the digital rain of the first film, all one cell wide.
local GLYPHS = vim.fn.split(
  'ﾊﾋｼﾂｳｰﾅﾐﾓﾆｻﾜｵﾘﾎﾏｴｷﾑﾃｹﾒｶﾕﾗｾﾈｽﾀﾇ'
    .. '0123456789Z'
    .. [[:."=*+-<>¦|_]],
  '\\zs'
)

---Random glyphs and gaps that fill exactly `width` cells, so the layout never shifts.
---Gaps and padded glyphs keep the rain airy, like the film.
---@param width integer
---@return string[] parts
local function random_parts(width)
  local parts = {}
  local remaining = width
  while remaining > 0 do
    local roll = math.random()
    local glyph = GLYPHS[math.random(#GLYPHS)]
    if remaining == 1 then
      parts[#parts + 1] = roll < 0.6 and glyph or ' '
      remaining = 0
    elseif roll < 0.4 then
      parts[#parts + 1] = WIDE_GLYPHS[math.random(#WIDE_GLYPHS)]
      remaining = remaining - 2
    elseif roll < 0.7 then
      parts[#parts + 1] = glyph .. ' '
      remaining = remaining - 2
    else
      parts[#parts + 1] = roll < 0.85 and glyph or ' '
      remaining = remaining - 1
    end
  end
  return parts
end

---Reorder in place. The parts stay the same, so the width stays the same.
---@param parts string[]
local function shuffle(parts)
  for index = #parts, 2, -1 do
    local other = math.random(index)
    parts[index], parts[other] = parts[other], parts[index]
  end
end

---Split the range into one run per line, spaces and indent included.
---@param buf integer
---@param range InlinePrompt.Range
---@return InlinePrompt.Run[]
local function find_runs(buf, range)
  local lines = vim.api.nvim_buf_get_text(buf, range.start_row, range.start_col, range.end_row, range.end_col, {})

  local runs = vim
    .iter(ipairs(lines))
    :filter(function(_, line) return line ~= '' end)
    :map(
      function(index, line)
        return {
          row = range.start_row + index - 1,
          col = index == 1 and range.start_col or 0,
          parts = random_parts(vim.fn.strdisplaywidth(line)),
        }
      end
    )
    :totable()

  -- Show one glyph when the range has no character, for example when inserting at the cursor.
  if #runs == 0 then
    return { { row = range.start_row, col = range.start_col, parts = random_parts(1), inline = true } }
  end
  return runs
end

---Reorder the random glyphs covering the range at every `shuffle_interval` until stopped.
---@public
---@param buf integer
---@param get_range fun(): InlinePrompt.Range? Current range, which can move while the request runs
---@return fun() stop
function M.start(buf, get_range)
  local namespace = vim.api.nvim_create_namespace('')
  local timer = assert(vim.uv.new_timer())
  ---@type InlinePrompt.Layout?
  local layout

  local function stop()
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
    end
  end

  -- Glyphs are picked when the text or the range changes, then only reordered on each tick.
  ---@param range InlinePrompt.Range
  ---@return InlinePrompt.Run[]
  local function current_runs(range)
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    if not layout or layout.tick ~= tick or not vim.deep_equal(layout.range, range) then
      vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
      layout = { tick = tick, range = range, runs = find_runs(buf, range) }
    end
    return layout.runs
  end

  timer:start(
    0,
    config.options.shuffle_interval,
    vim.schedule_wrap(function()
      local range = vim.api.nvim_buf_is_loaded(buf) and get_range()
      if not range then
        stop()
        return
      end

      -- Reusing the extmark id updates it in place instead of creating a new one.
      for index, run in ipairs(current_runs(range)) do
        shuffle(run.parts)
        vim.api.nvim_buf_set_extmark(buf, namespace, run.row, run.col, {
          id = index,
          virt_text = { { table.concat(run.parts), 'Comment' } },
          virt_text_pos = run.inline and 'inline' or 'overlay',
          hl_mode = 'combine',
        })
      end
    end)
  )

  return stop
end

return M
