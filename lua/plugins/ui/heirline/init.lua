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
          for _, client in ipairs(vim.lsp.get_clients()) do
            if client and client.name ~= '' then
              local spinner = get_client_spinner(client_messages, client.name)
              table.insert(client_names, spinner .. ' ' .. client.name)
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
