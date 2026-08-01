---@class Codex.AuthPage.Assets
---@field page string
---@field card string
---@field styles string
---@field auto_close string
---@field neovim_mark string
---@field icon_check string
---@field icon_cross string

---@class Codex.AuthPage
local M = {}

local source = debug.getinfo(1, 'S').source
local root = vim.fs.dirname(source:sub(2))

---@param filename string
---@return string
local function read_asset(filename)
  local path = vim.fs.joinpath(root, filename)
  local file, open_error = io.open(path, 'r')
  assert(file, string.format('Could not open Codex authentication page asset %s: %s', path, open_error))

  local content = file:read('*a')
  file:close()
  return content
end

---@type Codex.AuthPage.Assets
local assets = {
  page = read_asset('page.html'),
  card = read_asset('card.html'),
  styles = read_asset('styles.css'),
  auto_close = read_asset('auto-close.js'),
  neovim_mark = read_asset('neovim-mark.svg'),
  icon_check = read_asset('check.svg'),
  icon_cross = read_asset('cross.svg'),
}

---@param value string
---@return string
local function escape_html(value)
  return value:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'):gsub("'", '&#39;')
end

---@param template string
---@param values table<string, string>
---@return string
local function render_template(template, values)
  for key, value in pairs(values) do
    local marker = 'AUTH_PAGE_' .. key
    template = template:gsub('<!%-%- ' .. marker .. ' %-%->', function() return value end)
    template = template:gsub('/%* ' .. marker .. ' %*/', function() return value end)
    template = template:gsub(marker, function() return value end)
  end

  local missing = template:match('AUTH_PAGE_([A-Z_]+)')
  assert(not missing, string.format('Missing Codex authentication page template value: %s', missing))
  return template
end

---@param status 'success'|'error'
---@param headline string
---@param message string
---@param footnote string
---@param detail? string
---@return string
local function render_card(status, headline, message, footnote, detail)
  local escaped_detail = detail and escape_html(vim.trim(detail)) or ''

  return render_template(assets.card, {
    STATUS = status,
    NEOVIM_MARK = assets.neovim_mark,
    ICON_CHECK = assets.icon_check,
    ICON_CROSS = assets.icon_cross,
    HEADLINE = escape_html(headline),
    MESSAGE = escape_html(message),
    DETAIL_EMPTY = tostring(escaped_detail == ''),
    DETAIL_CONTENT = escaped_detail,
    FOOTNOTE = escape_html(footnote),
  })
end

---@param title string
---@param body string
---@param script? string
---@return string
local function render_document(title, body, script)
  return render_template(assets.page, {
    TITLE = escape_html(title),
    STYLES = assets.styles,
    BODY = body,
    SCRIPT = script or '',
  })
end

---Render a successful Codex authorization page.
---@public
---@return string
function M.success()
  return render_document(
    'Authorization successful',
    render_card(
      'success',
      'Authorization successful',
      'Neovim is now connected to ChatGPT.',
      'You can close this window and return to Neovim.'
    ),
    assets.auto_close
  )
end

---Render a failed Codex authorization page.
---@public
---@param detail string
---@return string
function M.error(detail)
  return render_document(
    'Authorization failed',
    render_card(
      'error',
      'Authorization failed',
      "Neovim couldn't finish connecting to ChatGPT.",
      'Close this window and try again from Neovim.',
      detail
    )
  )
end

return M
