vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. '/local/statusline')

local statusline = require('statusline')
vim.o.laststatus = 3
vim.o.columns = 180
vim.o.cmdheight = 0

---@param name string
---@param callback fun()
---@param iterations integer
local function benchmark(name, callback, iterations)
  for _ = 1, 20 do
    callback()
  end
  collectgarbage('collect')
  local samples = {}
  local total = 0
  for index = 1, iterations do
    local start = vim.uv.hrtime()
    callback()
    local elapsed = (vim.uv.hrtime() - start) / 1000
    samples[index] = elapsed
    total = total + elapsed
  end
  table.sort(samples)
  print(('%s: mean %.2f us, p95 %.2f us'):format(name, total / iterations, samples[math.ceil(iterations * 0.95)]))
end

statusline.setup({
  left = { { provider = ' %f %m', format = true } },
  right = { { provider = '%l:%c ', format = true } },
})
benchmark('core without center', statusline.render, 10000)
statusline.setup({
  left = { { provider = ' %f %m', format = true } },
  center = { { provider = 'CENTER' } },
  right = { { provider = '%l:%c ', format = true } },
})
benchmark('core with center', statusline.render, 10000)

local spec = require('plugins.ui.statusline')
spec.config(nil, spec.opts())
benchmark('configured render', statusline.render, 10000)
benchmark(
  'configured render and native evaluation',
  function() vim.api.nvim_eval_statusline(vim.o.statusline, { maxwidth = vim.o.columns }) end,
  10000
)

local line = string.rep('ordinary content without the matching word ', 5)
local lines = {}
for index = 1, 100000 do
  lines[index] = line
end
lines[#lines] = 'rare_target'
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.fn.setreg('/', 'rare_target')
vim.v.hlsearch = 1
vim.fn.searchcount({ recompute = true })
benchmark('100k lines active search', statusline.render, 50)
vim.v.hlsearch = 0

local tasks = {}
for index = 1, 2000 do
  tasks[index] = { status = index % 2 == 0 and 'SUCCESS' or 'RUNNING' }
end
local task_calls = 0
package.loaded.overseer = {
  ---@param _ table
  ---@return table[]
  list_tasks = function(_)
    task_calls = task_calls + 1
    return tasks
  end,
}
benchmark('2000 synthetic task entries', statusline.render, 10000)
print(('task list calls: %d'):format(task_calls))

local writes = 0
local set_highlight = vim.api.nvim_set_hl
---@param namespace integer
---@param name string
---@param highlight table
vim.api.nvim_set_hl = function(namespace, name, highlight)
  writes = writes + 1
  return set_highlight(namespace, name, highlight)
end
for _ = 1, 100 do
  vim.api.nvim_exec_autocmds('User', { pattern = 'OverseerListUpdate' })
end
print(('highlight writes per 100 task events: %d'):format(writes))
vim.api.nvim_set_hl = set_highlight
