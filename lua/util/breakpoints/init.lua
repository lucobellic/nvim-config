---@class dap.bp.extended: dap.bp
---@field log_message string|nil
---@field hit_condition string|nil

---@class DAP_BREAKPOINT
---@field filename string
---@field breakpoints dap.bp.extended[]

local M = {}

--- Save DAP breakpoints to a JSON file
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

  local breakpoints_file = session_file .. '.dap_breakpoints.json'
  vim.fn.writefile({ vim.json.encode(breakpoints) }, breakpoints_file)
  vim.g.DapBreakpointsPath = breakpoints_file
end

--- Restore DAP breakpoints from JSON file
function M.restore_breakpoints()
  local has_dap, dap_breakpoints = pcall(require, 'dap.breakpoints')
  if not has_dap then
    return
  end

  local file_path = vim.g.DapBreakpointsPath
  if not file_path or vim.fn.filereadable(file_path) == 0 then
    return
  end

  local ok, json_data = pcall(vim.fn.readfile, file_path)
  if not ok or not json_data or #json_data == 0 then
    return
  end

  local breakpoints_data
  ok, breakpoints_data = pcall(vim.json.decode, table.concat(json_data, '\n'))
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

--- Clear breakpoints by deleting the JSON file
function M.clear_breakpoints()
  vim.fn.delete(vim.g.DapBreakpointsPath)
  vim.g.DapBreakpointsPath = nil
end

return M
