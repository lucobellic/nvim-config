local M = {}

--- Find the first non-edgy, non-floating, normal editing window on the current tabpage.
--- Skips the calling window so the file is never opened back into the source buffer.
local function find_non_edgy_win()
  local source_win = vim.api.nvim_get_current_win()
  return vim.iter(vim.api.nvim_tabpage_list_wins(0)):find(function(winid)
    if winid == source_win then
      return false
    end
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local is_edgy = vim.b[bufnr].edgy_keys ~= nil and vim.b[bufnr].edgy_disable ~= true
    local is_floating = vim.api.nvim_win_get_config(winid).relative ~= ''
    local buftype = vim.bo[bufnr].buftype
    return not is_edgy and not is_floating and (buftype == '' or buftype == 'acwrite')
  end)
end

--- Open file under cursor in a non-edgy window, replicating gf / gF behavior.
--- Respects &path and &suffixesadd exactly as native gf does.
--- If no valid non-edgy window exists, opens a new split (mirrors native gf fallback).
--- @param with_lnum? boolean If true, also jump to line number (gF behavior)
function M.open_file(with_lnum)
  local cfile = vim.fn.expand('<cfile>')

  local fname = cfile
  local lnum = nil
  if with_lnum then
    -- gF recognizes a trailing :lnum suffix on the filename
    local name, n = cfile:match('^(.+):(%d+)$')
    if name and n then
      fname = name
      lnum = tonumber(n)
    end
  end

  -- Resolve using &path with upward search (;), then plain fallback — mirrors native gf
  local files = vim.fn.findfile(fname, vim.o.path .. ';')
  local found = vim.islist(files) and files[1] or files

  if found == '' then
    found = vim.fn.findfile(fname)
  end

  if found == '' or vim.fn.filereadable(found) == 0 then
    vim.notify('Can\'t find file "' .. fname .. '" in path', vim.log.levels.ERROR)
    return
  end

  local target_win = find_non_edgy_win()
  if target_win then
    vim.api.nvim_set_current_win(target_win)
  else
    -- No valid non-edgy window: open a new split, mirroring native gf fallback
    vim.cmd('new')
  end

  vim.cmd('edit ' .. vim.fn.fnameescape(found))

  if lnum then
    vim.api.nvim_win_set_cursor(0, { lnum, 0 })
  end
end

--- @return [number, number, number, number] [number, number, number, number] tuple of [buffer, line, col, off]
function M.get_visual_selection_range()
  local vpos = vim.fn.getpos('v')
  local dotpos = vim.fn.getpos('.')

  if vpos[2] > dotpos[2] or vpos[2] == dotpos[2] and vpos[3] > dotpos[3] then
    vpos, dotpos = dotpos, vpos
  end

  return vpos, dotpos
end

function M.get_visual_selection_text()
  local cursor_start, cursor_end = M.get_visual_selection_range()
  local bufnr = cursor_start[1]
  local text =
    vim.api.nvim_buf_get_text(bufnr, cursor_start[2] - 1, cursor_start[3] - 1, cursor_end[2] - 1, cursor_end[3], {})
  return table.concat(text, '\n')
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
