local config = require('inline-prompt.config')

---@class InlinePrompt.Run
---@field row integer
---@field col integer
---@field chars string[]

---@class InlinePrompt.Shuffle
local M = {}

-- Shown when the range has no visible character, for example when inserting at the cursor.
local PLACEHOLDERS = { '░', '▒', '▓' }

---@param items any[]
local function shuffle(items)
  for index = #items, 2, -1 do
    local other = math.random(index)
    items[index], items[other] = items[other], items[index]
  end
end

---Split the range into runs of visible characters, so spaces and tabs keep their place.
---@param buf integer
---@param range InlinePrompt.Range
---@return InlinePrompt.Run[]
local function find_runs(buf, range)
  local lines = vim.api.nvim_buf_get_text(buf, range.start_row, range.start_col, range.end_row, range.end_col, {})
  local runs = {}

  for index, line in ipairs(lines) do
    local first_col = index == 1 and range.start_col or 0
    for start, text in line:gmatch('()(%S+)') do
      table.insert(runs, {
        row = range.start_row + index - 1,
        col = first_col + start - 1,
        chars = vim.fn.split(text, '\\zs'),
      })
    end
  end

  return runs
end

---Shuffle characters of the same display width together, so wide characters never overlap their neighbors.
---@param runs InlinePrompt.Run[]
---@return string[] texts One shuffled text per run
local function shuffled_texts(runs)
  local pools = {}
  for _, run in ipairs(runs) do
    for _, char in ipairs(run.chars) do
      local width = vim.fn.strdisplaywidth(char)
      pools[width] = pools[width] or {}
      table.insert(pools[width], char)
    end
  end
  for _, pool in pairs(pools) do
    shuffle(pool)
  end

  return vim
    .iter(runs)
    :map(function(run)
      return vim
        .iter(run.chars)
        :map(function(char) return table.remove(pools[vim.fn.strdisplaywidth(char)]) end)
        :join('')
    end)
    :totable()
end

---@param buf integer
---@param namespace integer
---@param range InlinePrompt.Range
local function render(buf, namespace, range)
  vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)

  local runs = find_runs(buf, range)
  if #runs == 0 then
    vim.api.nvim_buf_set_extmark(buf, namespace, range.start_row, range.start_col, {
      virt_text = { { PLACEHOLDERS[math.random(#PLACEHOLDERS)], 'Comment' } },
      virt_text_pos = 'inline',
    })
    return
  end

  for index, text in ipairs(shuffled_texts(runs)) do
    vim.api.nvim_buf_set_extmark(buf, namespace, runs[index].row, runs[index].col, {
      virt_text = { { text, 'Comment' } },
      virt_text_pos = 'overlay',
      hl_mode = 'combine',
    })
  end
end

---Scramble the characters of the range at every `shuffle_interval` until stopped.
---@public
---@param buf integer
---@param get_range fun(): InlinePrompt.Range? Current range, which can move while the request runs
---@return fun() stop
function M.start(buf, get_range)
  local namespace = vim.api.nvim_create_namespace('')
  local timer = assert(vim.uv.new_timer())

  local function stop()
    if not timer:is_closing() then
      timer:stop()
      timer:close()
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
    end
  end

  timer:start(
    0,
    config.options.shuffle_interval,
    vim.schedule_wrap(function()
      local range = vim.api.nvim_buf_is_loaded(buf) and get_range()
      if range then
        render(buf, namespace, range)
      else
        stop()
      end
    end)
  )

  return stop
end

return M
