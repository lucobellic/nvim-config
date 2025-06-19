---@alias Sign {name:string, text:string, texthl:string, priority:number}

local M = {
  cache_ttl = 100,
  fold_cache_ttl = 100,
  empty_sign = { text = ' ' },
  fold_sign = { text = '', texthl = 'Constant' },

  -- Cache current time to avoid repeated os.clock() calls
  current_time = 0,
}
M.__index = M

-- Enhanced cache with proper invalidation
local cache = {
  -- Sign cache per buffer with timestamps
  signs_by_buf = {},
  signs_timestamp = {},

  -- Window/buffer state cache
  win_buf = {},
  win_opts = {},

  -- Fold states cache
  fold_states = {},
  fold_timestamp = {},

  -- Rendered content cache
  rendered = {},
  rendered_timestamp = {},
}

---@param sign? Sign
function M.icon(sign)
  if not sign or not sign.text then
    return ' '
  end

  local text = sign.text ~= '' and sign.text or ' '
  if sign.texthl then
    return ('%%#%s#%s'):format(sign.texthl, text):gsub('%s*$', '') .. '%*'
  end
  return text
end

-- Optimized sign retrieval with proper caching
---@return Sign[]
---@param buf number
function M.get_signs_cached(buf)
  M.current_time = vim.uv.hrtime() / 1000000 -- Convert to milliseconds

  -- Check if cache is valid
  local last_update = cache.signs_timestamp[buf] or 0
  if M.current_time - last_update < M.cache_ttl and cache.signs_by_buf[buf] then
    return cache.signs_by_buf[buf]
  end

  -- Fetch all signs for the buffer at once
  local signs_by_line = {}
  local extmarks = vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true, type = 'sign' })

  -- Process all extmarks once
  for _, extmark in ipairs(extmarks) do
    local lnum = extmark[2] + 1 -- Convert 0-based to 1-based
    if not signs_by_line[lnum] then
      signs_by_line[lnum] = {}
    end

    local details = extmark[4]
    if details then
      signs_by_line[lnum][#signs_by_line[lnum] + 1] = {
        name = details.sign_hl_group or details.sign_name or '',
        text = details.sign_text,
        texthl = details.sign_hl_group,
        priority = details.priority or 0,
      }
    end
  end

  -- Sort signs by priority for each line
  for lnum, signs in pairs(signs_by_line) do
    table.sort(signs, function(a, b) return a.priority < b.priority end)
  end

  -- Update cache
  cache.signs_by_buf[buf] = signs_by_line
  cache.signs_timestamp[buf] = M.current_time

  return signs_by_line
end

-- Get signs for a specific line from cache
---@param buf number
---@param lnum number
---@return Sign[]
function M.get_line_signs(buf, lnum)
  local signs_by_line = M.get_signs_cached(buf)
  return signs_by_line[lnum] or {}
end

-- Optimized fold state checking with caching
local function get_fold_state(win, lnum)
  M.current_time = M.current_time or vim.uv.hrtime() / 1000000

  local cache_key = win .. '_' .. lnum
  local last_update = cache.fold_timestamp[cache_key] or 0

  if M.current_time - last_update < M.fold_cache_ttl and cache.fold_states[cache_key] ~= nil then
    return cache.fold_states[cache_key]
  end

  local is_folded = false
  vim.api.nvim_win_call(win, function() is_folded = vim.fn.foldclosed(lnum) >= 0 end)

  cache.fold_states[cache_key] = is_folded
  cache.fold_timestamp[cache_key] = M.current_time

  return is_folded
end

-- Cached window option retrieval
local function get_win_opts(win)
  M.current_time = M.current_time or vim.uv.hrtime() / 1000000

  local last_update = cache.win_opts[win] and cache.win_opts[win].timestamp or 0
  if M.current_time - last_update < M.cache_ttl and cache.win_opts[win] then
    return cache.win_opts[win]
  end

  local opts = {
    signcolumn = vim.wo[win].signcolumn,
    number = vim.wo[win].number,
    relativenumber = vim.wo[win].relativenumber,
    timestamp = M.current_time,
  }

  cache.win_opts[win] = opts
  return opts
end

local function get_numbers(win, opts)
  local is_num = opts.number
  local is_relnum = opts.relativenumber

  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    return '%=%l%='
  end
  return '%='
end

-- Clear cache when appropriate (call this on buffer changes)
function M.clear_cache(buf)
  if buf then
    cache.signs_by_buf[buf] = nil
    cache.signs_timestamp[buf] = nil
    -- Clear fold cache for this buffer
    for key in pairs(cache.fold_states) do
      if key:match('^%d+_') then -- Remove fold cache entries
        cache.fold_states[key] = nil
        cache.fold_timestamp[key] = nil
      end
    end
  else
    -- Clear all caches
    cache.signs_by_buf = {}
    cache.signs_timestamp = {}
    cache.win_opts = {}
    cache.fold_states = {}
    cache.fold_timestamp = {}
    cache.rendered = {}
    cache.rendered_timestamp = {}
  end
end

local statuscolumn = {
  condition = function()
    return require('heirline.conditions').is_active() and vim.bo.buftype ~= 'nofile'
  end,
  provider = function()
    -- Early exit for virtual lines
    if vim.v.virtnum < 0 then
      return ''
    end

    local win = vim.api.nvim_get_current_win()
    local opts = get_win_opts(win)

    -- Early exit if signs are disabled
    if opts.signcolumn == 'no' then
      return get_numbers(win, opts)
    end

    -- Check render cache
    M.current_time = vim.uv.hrtime() / 1000000
    local cache_key = win .. '_' .. vim.v.lnum .. '_' .. vim.v.virtnum
    local cached = cache.rendered[cache_key]
    if cached and (M.current_time - cached.timestamp) < M.cache_ttl then
      return cached.content
    end

    local buf = vim.api.nvim_win_get_buf(win)
    local lnum = vim.v.lnum

    -- Initialize sign components
    local icon = M.empty_sign
    local git = M.empty_sign
    local fold = M.empty_sign

    -- Process signs efficiently
    local signs = M.get_line_signs(buf, lnum)
    for i = 1, #signs do
      local sign = signs[i]
      if sign.name then
        if sign.name:find('GitSign') then
          -- Prefer non-staged git signs
          if not (sign.name:find('Staged') and git ~= M.empty_sign) then
            git = sign
          end
        else
          icon = sign
        end
      end
    end

    -- Check fold state
    if get_fold_state(win, lnum) then
      fold = M.fold_sign
    end

    -- Build result
    local numbers = get_numbers(win, opts)
    local result = M.icon(icon) .. M.icon(git) .. numbers .. M.icon(fold) .. ' '

    -- Cache the result
    cache.rendered[cache_key] = {
      content = result,
      timestamp = M.current_time,
    }

    return result
  end,
}

-- Auto-clear cache on buffer changes
local group = vim.api.nvim_create_augroup('StatusColumnCache', { clear = true })
vim.api.nvim_create_autocmd({ 'BufWritePost', 'TextChanged', 'TextChangedI' }, {
  group = group,
  callback = function(args) M.clear_cache(args.buf) end,
})

return {
  fallthrough = false,
  statuscolumn,
  -- Export cache clearing function for manual use
  clear_cache = M.clear_cache,
}
