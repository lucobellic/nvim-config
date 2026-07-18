---@type snacks.picker.Config
local overseer_template = {
  layout = { preset = 'vscode' },
  win = {
    input = {
      keys = {
        ['<c-cr>'] = {
          'overseer_queue_template',
          mode = { 'n', 'i' },
          desc = 'Queue selected template',
        },
      },
    },
  },
  actions = {
    overseer_queue_template = function(picker)
      local items = picker:selected({ fallback = true })
      if #items > 0 then
        local queue = require('overseer.util.queue')
        vim.iter(items):each(function(item) queue.schedule({ name = item.item.name }) end)
      end
      picker:close()
    end,
  },
}

local overseer_task = {
  layout = { preset = 'vertical' },
  preview = function(ctx)
    local task = require('overseer.task_list').get(ctx.item.item.id)
    local bufnr = task and task:get_bufnr()
    if task and bufnr then
      ctx.preview:set_title(task.name)
      ctx.preview:set_buf(bufnr)
    else
      ctx.preview:set_title('Task output')
      ctx.preview:notify('No task output available')
    end
  end,
  win = {
    input = {
      keys = {
        ['<cr>'] = {
          'overseer_run_action_on_selected',
          mode = { 'n', 'i' },
          desc = 'Run action on selected tasks',
        },
      },
    },
  },
  actions = {
    overseer_run_action_on_selected = function(picker)
      local overseer = require('overseer')
      local actions = require('overseer.task_list.actions')
      local config = require('overseer.config')
      local task_list = require('overseer.task_list')
      local task_ids = vim.tbl_map(function(item) return item.item.id end, picker:selected({ fallback = true }))
      local tasks = vim.tbl_map(function(id) return task_list.get(id) end, task_ids)

      local available_actions = vim
        .iter(pairs(vim.tbl_deep_extend('force', actions, config.actions)))
        :filter(function(_, action)
          return action
            and vim.iter(tasks):any(function(task) return action.condition == nil or action.condition(task) end)
        end)
        :map(function(name, action) return { name = name, action = action } end)
        :totable()
      table.sort(available_actions, function(a, b) return a.name < b.name end)

      picker:close()
      vim.ui.select(available_actions, {
        prompt = 'Action for selected tasks',
        kind = 'overseer_task_options',
        format_item = function(item)
          if item.action.desc then
            return string.format('%s (%s)', item.name, item.action.desc)
          end
          return item.name
        end,
      }, function(item)
        if item then
          vim
            .iter(task_ids)
            :map(function(task_id) return task_list.get(task_id) end)
            :filter(function(task) return task and (item.action.condition == nil or item.action.condition(task)) end)
            :each(function(task) overseer.run_action(task, item.name) end)
        end
      end)
    end,
  },
}

return {
  'folke/snacks.nvim',
  opts = {
    picker = {
      sources = {
        select = {
          kinds = {
            overseer_template = overseer_template,
            overseer_task = overseer_task,
          },
        },
      },
    },
  },
}
