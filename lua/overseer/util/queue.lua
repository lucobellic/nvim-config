local M = {}

---@class QueueEntry
---@field task overseer.Task
---@field callback? fun(task: overseer.Task)

---@type QueueEntry[]
local queue = {}

---@type table<integer, fun()>
local subscribed_tasks = {}

local function notify(msg, level) vim.notify(msg, level, { title = 'Overseer Queue' }) end

---@return boolean
local function has_running_tasks()
  local overseer = require('overseer')
  local constants = require('overseer.constants')
  return #overseer.list_tasks({ status = constants.STATUS.RUNNING }) > 0
end

---@param task overseer.Task
local function subscribe_to_task(task)
  if subscribed_tasks[task.id] then
    return
  end
  local callback = vim.schedule_wrap(function()
    subscribed_tasks[task.id] = nil
    M.process()
  end)
  subscribed_tasks[task.id] = callback
  task:subscribe('on_complete', callback)
end

local function subscribe_to_running_tasks()
  local overseer = require('overseer')
  local constants = require('overseer.constants')
  local running = overseer.list_tasks({ status = constants.STATUS.RUNNING })
  vim.iter(running):each(subscribe_to_task)
end

local function unsubscribe_all()
  local overseer = require('overseer')
  local tasks = overseer.list_tasks()
  vim
    .iter(subscribed_tasks)
    :map(function(task_id, callback) return tasks[task_id], callback end)
    :filter(function(task, _) return task end)
    :each(function(task, callback) task:unsubscribe('on_complete', callback) end)
  subscribed_tasks = {}
end

function M.process()
  if #queue == 0 then
    unsubscribe_all()
    return
  end

  if has_running_tasks() then
    subscribe_to_running_tasks()
    return
  end

  local entry = table.remove(queue, 1)
  if not entry then
    return
  end

  -- Skip if task was externally started or disposed
  local constants = require('overseer.constants')
  if entry.task.status ~= constants.STATUS.PENDING then
    M.process()
    return
  end

  entry.task.metadata.queued = false
  notify('Starting queued task: ' .. entry.task.name, vim.log.levels.INFO)

  entry.task:start()

  entry.task:subscribe(
    'on_complete',
    vim.schedule_wrap(function()
      if entry.callback then
        entry.callback(entry.task)
      end
      M.process()
    end)
  )
end

---@param opts overseer.TemplateRunOpts
---@param callback? fun(task: overseer.Task)
function M.schedule(opts, callback)
  local overseer = require('overseer')
  local task_name = opts.name or '(unnamed)'

  overseer.run_task(vim.tbl_extend('force', opts, { autostart = false }), function(task)
    if not task then
      notify('Failed to create task: ' .. task_name, vim.log.levels.ERROR)
      return
    end
    M.schedule_task(task, callback)
  end)
end

---@param task overseer.Task
---@param callback? fun(task: overseer.Task)
function M.schedule_task(task, callback)
  local task_name = task.name or '(unnamed)'

  task.metadata.queued = true

  task:subscribe(
    'on_dispose',
    vim.schedule_wrap(function()
      queue = vim.iter(queue):filter(function(e) return e.task ~= task end):totable()
    end)
  )

  table.insert(queue, { task = task, callback = callback })
  notify('Queued task: ' .. task_name, vim.log.levels.INFO)
  M.process()
end

function M.clear()
  local count = #queue
  vim.iter(queue):each(function(entry) entry.task:dispose() end)
  queue = {}
  unsubscribe_all()
  if count > 0 then
    notify('Cleared ' .. count .. ' queued task(s)', vim.log.levels.INFO)
  end
end

---@return overseer.Task[]
function M.list()
  return vim.iter(queue):map(function(e) return e.task end):totable()
end

return M
