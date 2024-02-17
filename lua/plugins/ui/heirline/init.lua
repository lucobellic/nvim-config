local lsp_icons = require('plugins.ui.heirline.lsp_icons')
local ignored_clients = { 'copilot' }

---@param client_messages {name: string, body: string}[]
---@param client_name string
---@return string
local function get_client_spinner(client_messages, client_name)
  for _, message in ipairs(client_messages) do
    if message.name == client_name then
      return message.body
    end
  end
  return ''
end

return {
  'rebelot/heirline.nvim',
  enabled = true,
  event = 'UIEnter',
  dependencies = {
    'stevearc/overseer.nvim',
    {
      'linrongbin16/lsp-progress.nvim',
      opts = {
        spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
        client_format = function(client_name, spinner, series_messages)
          local not_done = vim.tbl_contains(
            series_messages,
            function(message) return not message.done end,
            { predicate = true }
          )
          return {
            name = client_name,
            body = not_done and spinner or '',
          }
        end,
        format = function(client_messages)
          local client_names = {}
          local clients = vim.tbl_filter(
            function(client) return vim.lsp.buf_is_attached(0, client.id) end,
            vim.lsp.get_clients({ buffer = 0 })
          )
          for _, client in ipairs(clients) do
            if client and not vim.tbl_contains(ignored_clients, client.name) then
              local spinner = get_client_spinner(client_messages, client.name)
              local client_icon = lsp_icons[client.name] or client.name
              table.insert(client_names, spinner .. ' ' .. client_icon)
            end
          end
          return table.concat(client_names, ' ')
        end,
      },
    },
  },
  config = function(_, default_opts)
    local heirline_opts = {
      statusline = require('plugins.ui.heirline.statusline'),
      opts = {
        colors = require('plugins.ui.heirline.colors').colors,
      },
    }
    local opts = vim.tbl_deep_extend('force', heirline_opts, default_opts) or {}
    require('heirline').setup(opts)
  end,
}
