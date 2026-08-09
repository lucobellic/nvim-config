---@class OscConfig.Opts
---@field selectors? (string|integer)[] OSC selectors forwarded to the host terminal

---@class OscConfig.TermRequestEvent
---@field data? { sequence?: string, terminator?: string }

---@class OscConfig
local M = {}

---@type table<string, boolean>
local allowed = {}

---@param sequence string
local function write_to_stderr(sequence)
  io.stderr:write(sequence)
  io.stderr:flush()
end

---@param sequence string
local function forward_to_host(sequence)
  local ok = pcall(vim.uv.fs_write, 2, sequence)
  if not ok then
    pcall(write_to_stderr, sequence)
  end
end

---@param selector string|integer
local function allow_selector(selector) allowed[tostring(selector)] = true end

---@param event OscConfig.TermRequestEvent
local function handle_request(event)
  local sequence = event.data and event.data.sequence
  if not sequence then
    return
  end

  local selector = sequence:match('^\27%](%d+)')
  if selector and allowed[selector] then
    forward_to_host(sequence .. (event.data.terminator or '\7'))
  end
end

---Forward selected OSC requests from embedded terminals to the host terminal.
---@public
---@param opts? OscConfig.Opts
function M.setup(opts)
  opts = opts or {}
  allowed = {}
  vim.iter(opts.selectors or {}):each(allow_selector)

  local group = vim.api.nvim_create_augroup('OscForwarding', { clear = true })
  vim.api.nvim_create_autocmd('TermRequest', {
    group = group,
    desc = 'Forward allowed OSC requests from embedded terminals',
    callback = handle_request,
  })
end

return M
