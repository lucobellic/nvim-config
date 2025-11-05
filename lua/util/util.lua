local M = {}

function M.open_file()
  -- Find the first open window with a valid buffer
  local buffers = vim.tbl_filter(
    function(buffer) return #buffer.windows >= 1 end,
    vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })
  )
  local first_window = #buffers > 0 and buffers[1].windows[1] or nil

  -- Open file under cursor in first valid window or in new window otherwise
  local filename = vim.fn.findfile(vim.fn.expand('<cfile>'))
  if vim.fn.filereadable(filename) == 1 then
    if first_window then
      vim.api.nvim_set_current_win(first_window)
    end
    vim.cmd('edit ' .. filename)
  else
    vim.notify('File does not exist: ' .. filename)
  end
end

---@generic T
---@param items T[] Arbitrary items
---@param opts? {prompt?: string, format_item?: (fun(item: T): string), kind?: string}
---@param on_choice fun(items?: T[], indices?: number[])
function M.multi_select(items, opts, on_choice)
  assert(type(on_choice) == 'function', 'on_choice must be a function')
  opts = opts or {}

  ---@type snacks.picker.finder.Item[]
  local finder_items = {}
  for idx, item in ipairs(items) do
    local text = (opts and opts.format_item or tostring)(item)
    table.insert(finder_items, {
      formatted = text,
      text = idx .. ' ' .. text,
      item = item,
      idx = idx,
    })
  end

  local title = opts.prompt or 'Select'
  title = title:gsub('^%s*', ''):gsub('[%s:]*$', '')
  local completed = false

  ---@type snacks.picker.finder.Item[]
  return Snacks.picker.pick({
    source = 'select',
    items = finder_items,
    format = 'text',
    title = title,
    matcher = {
      frecency = true,
      highlight = true,
    },
    layout = {
      layout = {
        preview = false,
        height = math.floor(math.min(vim.o.lines * 0.8 - 10, #items + 2) + 0.5),
      },
    },
    actions = {
      confirm = function(picker, item)
        if completed then
          return
        end
        completed = true
        picker:close()
        vim.schedule(function()
          local selected_items = picker:selected()
          if not selected_items or #selected_items == 0 then
            on_choice(item and { item.item } or {}, item and { item.idx } or {})
          else
            local result_items = {}
            local result_indices = {}
            for _, selected in ipairs(selected_items) do
              table.insert(result_items, selected.item)
              table.insert(result_indices, selected.idx)
            end
            on_choice(result_items, result_indices)
          end
        end)
      end,
    },
    on_close = function()
      if completed then
        return
      end
      completed = true
      vim.schedule(function() on_choice({}, {}) end)
    end,
  })
end

return M
