local shared = require('plugins.ui.statusline.components.shared')

---@type uv.uv_timer_t?
local timer

local function close_timer()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

return {
  dir = vim.fn.stdpath('config') .. '/local/statusline',
  name = 'statusline',
  lazy = false,
  ---@return User.Statusline.Options
  opts = function()
    if package.loaded.lazy then
      require('lazy.status')
    end
    local colors = {
      Normal = '#70809b',
      Insert = '#AAD94C',
      Visual = '#FFB454',
      Command = '#59C2FF',
      Select = '#D2A6FF',
      Replace = '#F07178',
      Terminal = '#D2A6FF',
    }
    local black = '#0F131A'
    ---@type table<string, vim.api.keyset.highlight|fun(): vim.api.keyset.highlight>
    local highlights = {
      UserStatuslineBase = { fg = colors.Normal },
      UserStatuslineMacro = { fg = colors.Visual, italic = true },
    }
    vim.iter(colors):each(
      ---@param mode string
      ---@param color string
      function(mode, color)
        highlights['UserStatuslinePrimary' .. mode] = {
          fg = mode == 'Normal' and color or black,
          bg = mode ~= 'Normal' and color or nil,
        }
        highlights['UserStatuslineSecondary' .. mode] = { fg = color }
      end
    )
    vim.iter(shared.task_symbols):each(
      ---@param entry string[]
      function(entry)
        ---@return vim.api.keyset.highlight
        highlights['UserStatuslineTask' .. entry[1]] = function()
          return { fg = vim.api.nvim_get_hl(0, { name = 'Overseer' .. entry[1], link = false, create = false }).fg }
        end
      end
    )

    return {
      highlight = 'UserStatuslineBase',
      highlights = highlights,
      highlight_update = { { event = 'User', pattern = { 'OverseerListUpdate', 'LazyLoad' } } },
      update = { { event = 'User', pattern = 'DapProgressUpdate' } },
      left = require('plugins.ui.statusline.components.left'),
      center = require('plugins.ui.statusline.components.center'),
      right = require('plugins.ui.statusline.components.right'),
    }
  end,
  ---@param _ LazyPlugin
  ---@param opts User.Statusline.Options
  config = function(_, opts)
    local statusline = require('statusline')
    close_timer()
    shared.requests = 0
    local group = vim.api.nvim_create_augroup('UserStatuslineIntegrations', { clear = true })
    vim.api.nvim_create_autocmd('User', {
      group = group,
      pattern = { 'CodeCompanionRequestStarted', 'CodeCompanionRequestFinished' },
      ---@param event vim.api.keyset.create_autocmd.callback_args
      callback = function(event)
        if event.match == 'CodeCompanionRequestStarted' then
          shared.requests = shared.requests + 1
          if not timer then
            shared.frame = 1
            timer = assert(vim.uv.new_timer())
            timer:start(
              200,
              200,
              vim.schedule_wrap(function()
                shared.frame = shared.frame % #shared.frames + 1
                statusline.redraw()
              end)
            )
          end
        else
          shared.requests = math.max(0, shared.requests - 1)
          if shared.requests == 0 then
            close_timer()
          end
        end
        statusline.redraw()
      end,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = close_timer })
    statusline.setup(opts)
  end,
}
