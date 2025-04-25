local Job = require('plenary.job')
local n = require('nui-components')
local spinner_formats = require('nui-components.utils.spinner-formats')

local min_width = 20
local max_width = 180
local renderer = n.create_renderer({
  width = 80,
  height = 1,
})

local function get_mr_list(signal, args)
  ---@diagnostic disable-next-line: missing-fields
  Job:new({
    command = 'glab',
    args = { 'mr', 'list', args },
    on_exit = function(j, exit_code)
      if exit_code ~= 0 then
        vim.notify('Failed to get gitlab issues', vim.log.levels.ERROR)
      else
        local data = vim
          .iter(j:result())
          :filter(function(issue) return issue:match('^!') end)
          :map(function(issue)
            local parts = vim.split(issue, '\t', { plain = true })
            return n.option(parts[3], { id = parts[1] })
          end)
          :totable()

        vim.schedule(function()
          signal.data = data
          signal.selected = { data[1].text }
          local width = vim.fn.max(vim.iter(data):map(function(item) return item.text:len() end):totable()) + 5
          width = vim.fn.max({width, min_width})
          width = vim.fn.min({width, max_width})
          renderer:set_size({
            height = #data + 3,
            width = width
          })
          signal.is_loading = false
          signal.is_visible = true
        end)
      end
    end,
  }):start()
end

local tab_signal = n.create_signal({ active_tab = 'assigned' })
local is_tab_active = n.is_active_factory(tab_signal.active_tab)

local select_signal = n.create_signal({
  selected = { 'loading...' },
  data = { n.option('loading...') },
  is_visible = false,
  is_loading = false,
  width = 120,
})

local function tab_bar()
  return n.columns(
    { flex = 0 },
    n.paragraph({ flex = 1, lines = '', align = 'left', is_focusable = false }),
    n.button({
      label = 'Assigned',
      autofocus = true,
      is_active = is_tab_active('assigned'),
      on_press = function()
        select_signal.is_loading = true
        select_signal.is_visible = false
        tab_signal.active_tab = 'assigned'
        vim.defer_fn(function()
          vim.schedule(function() get_mr_list(select_signal, '--assignee=@me') end)
        end, 1000)
      end,
    }),
    n.gap({ flex = 1 }),
    n.button({
      label = 'Reviews',
      is_active = is_tab_active('reviews'),
      on_press = function()
        select_signal.is_loading = true
        select_signal.is_visible = false
        select_signal.frames = spinner_formats.dots
        tab_signal.active_tab = 'reviews'
        vim.defer_fn(function()
          vim.schedule(function() get_mr_list(select_signal, '--reviewer=@me') end)
        end, 1000)
      end,
    }),
    n.paragraph({ flex = 1, lines = '', align = 'righ', is_focusable = false }),
    n.paragraph({ lines = '    ', align = 'right', is_focusable = false, hidden = select_signal.is_loading }),
    n.spinner({
      is_loading = select_signal.is_loading,
      padding = { right = 1 },
      hidden = select_signal.is_loading:negate(),
    })
  )
end

local body = function()
  return n.tabs(
    { active_tab = tab_signal.active_tab },
    tab_bar(),
    n.gap(1),
    n.tab(
      { id = 'assigned' },
      n.select({
        flex = 1,
        border_label = 'My Issues',
        selected = select_signal.selected,
        data = select_signal.data,
        hidden = select_signal.is_visible:negate(),
        on_select = function(nodes)
          -- TODO: open web link
        end,
      })
    ),
    n.tab(
      { id = 'reviews' },
      n.select({
        flex = 1,
        border_label = 'Reviews',
        selected = select_signal.selected,
        data = select_signal.data,
        hidden = select_signal.is_visible:negate(),
        on_select = function(nodes)
          -- TODO: open web link
        end,
      })
    )
  )
end

renderer:render(body)
