---@class User.Statusline.Context
---@field winid integer
---@field bufnr integer
---@field width integer Available display cells
---@field active boolean
---@field mode string

---@class User.Statusline.Event
---@field event string|string[]
---@field pattern? string|string[]

---@alias User.Statusline.Update (string|User.Statusline.Event)[]
---@alias User.Statusline.Provider string|fun(context: User.Statusline.Context): string

---@class User.Statusline.Component
---@field provider User.Statusline.Provider
---@field condition? fun(context: User.Statusline.Context): boolean
---@field hl? string|fun(context: User.Statusline.Context): string
---@field padding? {left?: integer, right?: integer}
---@field format? boolean Interpret provider output as native statusline syntax
---@field update? User.Statusline.Update Cache provider output until these events

---@class User.Statusline.Options
---@field left? User.Statusline.Component[]
---@field center? User.Statusline.Component[]
---@field right? User.Statusline.Component[]
---@field highlight? string Base highlight for sections and spacing
---@field highlights? table<string, vim.api.keyset.highlight|fun(): vim.api.keyset.highlight>
---@field highlight_update? User.Statusline.Update Refresh dynamic highlight definitions
---@field update? User.Statusline.Update Request redraws without caching components

---@class User.Statusline.Cache
---@field bufnr integer
---@field width integer
---@field active boolean
---@field mode string
---@field text string

---@class User.Statusline.Compiled
---@field spec User.Statusline.Component
---@field before string
---@field after string
---@field text? string
---@field output? string
---@field cache? table<integer, User.Statusline.Cache>

---@class User.Statusline
local M = {}

---@type User.Statusline.Compiled[][]
local sections = { {}, {}, {} }
---@type User.Statusline.Compiled[]
local components = {}
---@type User.Statusline.Options
local options = {}
---@type table<string, vim.api.keyset.highlight>
local highlights = {}
local base = ''
local reset = '%*'
local redraw_pending = false
local group

---Escape literal text before including it in a statusline format.
---@public
---@param text string
---@return string
function M.escape(text)
  local escaped = text:gsub('%%', '%%%%')
  return escaped
end

---Wrap a native format in a highlight and restore the surrounding group.
---@public
---@param format string
---@param highlight string
---@param restore? string
---@return string
function M.highlight(format, highlight, restore)
  return '%#' .. highlight .. '#' .. format .. (restore and ('%#' .. restore .. '#') or '%*')
end

---Coalesce update requests into one scheduled redraw.
---@public
function M.redraw()
  if redraw_pending then
    return
  end
  redraw_pending = true
  vim.schedule(function()
    redraw_pending = false
    vim.cmd.redrawstatus()
  end)
end

---@param component User.Statusline.Compiled
---@param text string
---@return string
local function format_text(component, text)
  if text == '' then
    return ''
  end
  return component.before .. (component.spec.format and text or M.escape(text)) .. component.after
end

---@param updates? User.Statusline.Update
---@param callback fun(event: vim.api.keyset.create_autocmd.callback_args)
local function subscribe(updates, callback)
  vim.iter(updates or {}):each(
    ---@param update string|User.Statusline.Event
    function(update)
      local event = type(update) == 'string' and { event = update } or update
      vim.api.nvim_create_autocmd(event.event, { group = group, pattern = event.pattern, callback = callback })
    end
  )
end

---@param specs? User.Statusline.Component[]
---@return User.Statusline.Compiled[]
local function compile(specs)
  return vim
    .iter(specs or {})
    :map(
      ---@param spec User.Statusline.Component
      ---@return User.Statusline.Compiled
      function(spec)
        local padding = spec.padding or {}
        ---@type User.Statusline.Compiled
        local component = {
          spec = spec,
          before = string.rep(' ', padding.left or 0),
          after = string.rep(' ', padding.right or 0),
        }
        if type(spec.provider) == 'string' then
          component.text = format_text(component, spec.provider)
          if type(spec.hl) ~= 'function' then
            component.output = component.text == '' and ''
              or ((spec.hl and ('%#' .. spec.hl .. '#') or base) .. component.text .. reset)
          end
        elseif spec.update then
          component.cache = {}
        end
        subscribe(spec.update, function()
          if component.cache then
            component.cache = {}
          end
          M.redraw()
        end)
        components[#components + 1] = component
        return component
      end
    )
    :totable()
end

---@param component User.Statusline.Compiled
---@param context User.Statusline.Context
---@return string
local function render_component(component, context)
  local spec = component.spec
  if spec.condition and not spec.condition(context) then
    return ''
  end
  if component.output then
    return component.output
  end
  local text = component.text
  if not text then
    local cached = component.cache and component.cache[context.winid]
    if
      cached
      and cached.bufnr == context.bufnr
      and cached.width == context.width
      and cached.active == context.active
      and cached.mode == context.mode
    then
      text = cached.text
    else
      local provider = spec.provider
      ---@cast provider fun(context: User.Statusline.Context): string
      text = format_text(component, provider(context))
      if component.cache then
        component.cache[context.winid] = {
          bufnr = context.bufnr,
          width = context.width,
          active = context.active,
          mode = context.mode,
          text = text,
        }
      end
    end
  end
  if text == '' then
    return ''
  end
  local highlight = type(spec.hl) == 'function' and spec.hl(context) or spec.hl
  return (highlight and ('%#' .. highlight .. '#') or base) .. text .. reset
end

---@param section User.Statusline.Compiled[]
---@param context User.Statusline.Context
---@return string
local function render_section(section, context)
  local parts = {}
  vim.iter(section):each(
    ---@param component User.Statusline.Compiled
    function(component) parts[#parts + 1] = render_component(component, context) end
  )
  return table.concat(parts)
end

---Render components with a center fixed to the full statusline width.
---@public
---@return string
function M.render()
  local current = vim.api.nvim_get_current_win()
  local winid = vim.g.statusline_winid or current
  ---@type User.Statusline.Context
  local context = {
    winid = winid,
    bufnr = vim.api.nvim_win_get_buf(winid),
    width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(winid),
    active = winid == current,
    mode = vim.api.nvim_get_mode().mode,
  }
  local left = render_section(sections[1], context)
  local center = render_section(sections[2], context)
  local right = render_section(sections[3], context)
  local sides = base .. '%<' .. left .. reset .. '%=' .. right .. reset
  if center == '' then
    return sides
  end
  local measure = { winid = winid, maxwidth = context.width + 1 }
  local center_width = vim.api.nvim_eval_statusline(center, measure).width
  if center_width == 0 then
    return sides
  end
  local left_width = vim.api.nvim_eval_statusline(left, measure).width
  local right_width = vim.api.nvim_eval_statusline(right, measure).width
  local center_start = math.floor((context.width - center_width) / 2)
  local left_gap = center_start - left_width
  local right_gap = context.width - right_width - center_start - center_width
  if left_gap < 0 or right_gap < 0 then
    return sides
  end
  return base
    .. left
    .. reset
    .. string.rep(' ', left_gap)
    .. center
    .. reset
    .. string.rep(' ', right_gap)
    .. right
    .. reset
end

---@param force boolean
local function refresh_highlights(force)
  vim.iter(options.highlights or {}):each(
    ---@param name string
    ---@param definition vim.api.keyset.highlight|fun(): vim.api.keyset.highlight
    function(name, definition)
      if force or type(definition) == 'function' then
        local value = type(definition) == 'function' and definition() or definition
        if force or not vim.deep_equal(highlights[name], value) then
          vim.api.nvim_set_hl(0, name, value)
          highlights[name] = vim.deepcopy(value)
        end
      end
    end
  )
end

---Compile component tables, install highlights and subscribe to updates.
---@public
---@param config User.Statusline.Options
function M.setup(config)
  options = config
  components = {}
  highlights = {}
  base = config.highlight and ('%#' .. config.highlight .. '#') or ''
  reset = base ~= '' and base or '%*'
  group = vim.api.nvim_create_augroup('UserStatusline', { clear = true })
  sections = { compile(config.left), compile(config.center), compile(config.right) }
  refresh_highlights(true)
  subscribe(config.update, M.redraw)
  subscribe(config.highlight_update, function()
    refresh_highlights(false)
    M.redraw()
  end)
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      refresh_highlights(true)
      vim.schedule(function() refresh_highlights(false) end)
      M.redraw()
    end,
  })
  vim.api.nvim_create_autocmd('ModeChanged', { group = group, callback = M.redraw })
  vim.api.nvim_create_autocmd('WinClosed', {
    group = group,
    ---@param event vim.api.keyset.create_autocmd.callback_args
    callback = function(event)
      local winid = tonumber(event.match)
      vim.iter(components):each(
        ---@param component User.Statusline.Compiled
        function(component)
          if component.cache then
            component.cache[winid] = nil
          end
        end
      )
    end,
  })
  vim.o.statusline = "%!v:lua.require'statusline'.render()"
end

return M
