---@class dap.bp.extended: dap.bp
---@field log_message string|nil
---@field hit_condition string|nil

---@class DAP_BREAKPOINT
---@field filename string
---@field breakpoints dap.bp.extended[]

local M = {}

--- Save DAP breakpoints
---@param session_file string
function M.save_breakpoints(session_file)
  if not session_file or session_file == '' then
    return
  end

  local has_dap, dap_breakpoints = pcall(require, 'dap.breakpoints')
  if not has_dap then
    return
  end

  ---@type DAP_BREAKPOINT[]
  local breakpoints = vim
    .iter(pairs(dap_breakpoints.get() or {}))
    :map(
      ---@param buffer number
      ---@param breakpoints dap.bp[]
      function(buffer, breakpoints)
        local filename = vim.api.nvim_buf_get_name(buffer)
        -- Add log_message and hit_condition fields due to malformed behavior in dap save/load
        local transformed_breakpoints = vim
          .iter(breakpoints)
          :map(
            ---@param breakpoint dap.bp
            ---@return dap.bp.extended
            function(breakpoint)
              ---@diagnostic disable-next-line: inject-field
              breakpoint.log_message = breakpoint.logMessage
              ---@diagnostic disable-next-line: inject-field
              breakpoint.hit_condition = breakpoint.hitCondition
              return breakpoint
            end
          )
          :totable()

        return { filename = filename, breakpoints = transformed_breakpoints }
      end
    )
    :totable()

  vim.g.DapBreakpoints = vim.json.encode(breakpoints)
end

--- Restore DAP breakpoints
function M.restore_breakpoints()
  local has_dap, dap_breakpoints = pcall(require, 'dap.breakpoints')
  if not has_dap then
    return
  end

  local ok, breakpoints_data = pcall(vim.json.decode, vim.g.DapBreakpoints or '{}')
  if not ok or not breakpoints_data then
    return
  end

  dap_breakpoints.clear()
  vim.iter(breakpoints_data or {}):each(
    ---@param breakpoints_info DAP_BREAKPOINT
    function(breakpoints_info)
      local buffer = vim.fn.bufnr(breakpoints_info.filename, true)
      vim.iter(breakpoints_info.breakpoints):each(
        ---@param breakpoint dap.bp.extended
        function(breakpoint) dap_breakpoints.set(breakpoint, buffer, breakpoint.line) end
      )
    end
  )
end

--- Clear breakpoints
function M.clear_breakpoints() vim.g.DapBreakpoints = '{}' end

--- Use snacks picker to select breakpoints to jump to
---@param filter? snacks.picker.filter.Config
function M.pick(filter)
  filter = filter or {}

  local dap_breakpoints = require('dap.breakpoints')

  local function format_breakpoint_item(item, picker) return Snacks.picker.format.filename(item, picker) end

  local function breakpoint_finder()
    local breakpoints = dap_breakpoints.get()

    return vim
      .iter(breakpoints or {})
      :flatten()
      :filter(function( breakpoint) return vim.api.nvim_buf_is_valid(breakpoint.buf) end)
      :enumerate()
      :map(
        ---@param idx number
        ---@param breakpoint dap.bp
        function(idx, breakpoint)
          local path = vim.api.nvim_buf_get_name(breakpoint.buf)
          local short_path = vim.fn.fnamemodify(path, ':~:.')
          return {
            formatted = short_path .. ':' .. breakpoint.line,
            text = idx .. ' ' .. short_path .. ':' .. breakpoint.line,
            file = path,
            pos = { breakpoint.line, 0 },
            item = breakpoint,
            idx = idx,
          }
        end
      )
      :totable()
  end

  Snacks.picker.pick({
    source = 'breakpoints',
    format = format_breakpoint_item,
    layout = { preset = 'telescope_vertical' },
    title = 'Breakpoints',
    filter = filter,
    finder = function(_, ctx) return ctx.filter:filter(breakpoint_finder()) end,
    actions = {
      confirm = function(picker, item)
        picker:close()
        vim.schedule(function()
          if vim.fn.filereadable(item.file) == 1 then
            vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
            vim.api.nvim_win_set_cursor(0, item.pos)
          else
            vim.notify('File not found: ' .. item.file, vim.log.levels.ERROR, { title = 'Notes' })
          end
        end)
      end,
      remove = function(picker)
        local selected = picker:selected({ fallback = true })
        vim.iter(selected):each(function(item)
          ---@type dap.bp
          local breakpoint = item.item
          dap_breakpoints.remove(breakpoint.buf, breakpoint.line)
        end)

        picker.list:set_selected()
        picker.list:set_target()
        picker:find()
      end,
    },
    win = {
      input = {
        keys = {
          ['<c-x>'] = { 'remove', mode = { 'i', 'n' } },
        },
      },
    },
  })
end

return M
