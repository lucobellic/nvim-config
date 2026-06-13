--- Editor client module for opening files in parent Neovim instance
--- Mimics vim-floaterm's edita mechanism to prevent nested nvim instances
---@class EditorClient
local M = {}

--- Get the Neovim server address from environment
---@return string? server address (unix socket or tcp address)
local function get_server_address()
  -- Check $NVIM first (standard in modern Neovim), then fallback to $NVIM_LISTEN_ADDRESS
  ---@diagnostic disable-next-line: undefined-field
  local server = vim.env.NVIM or vim.env.NVIM_LISTEN_ADDRESS
  if not server or server == '' then
    return nil
  end
  return server
end

--- Determine connection mode (tcp or pipe) based on address format
---@param address string Server address
---@return 'tcp'|'pipe'
local function get_connection_mode(address)
  -- TCP if address matches IP:port or localhost:port format
  if address:match('^%d+%.%d+%.%d+%.%d+:%d+$') or address:match('^localhost:%d+$') then
    return 'tcp'
  end
  return 'pipe'
end

--- Open file in parent Neovim instance using RPC
---@param filepath string File path to open
---@return boolean success
function M.open_in_parent(filepath)
  if not filepath or filepath == '' then
    vim.notify('term: no file path provided to editor client', vim.log.levels.ERROR)
    return false
  end

  local server = get_server_address()
  if not server then
    vim.notify('term: no parent Neovim instance found (NVIM/NVIM_LISTEN_ADDRESS not set)', vim.log.levels.ERROR)
    return false
  end

  -- Resolve to absolute path
  local abs_path = vim.fn.fnamemodify(filepath, ':p')
  if not abs_path or abs_path == '' then
    vim.notify('term: failed to resolve file path: ' .. tostring(filepath), vim.log.levels.ERROR)
    return false
  end

  local mode = get_connection_mode(server)
  local ok, channel = pcall(vim.fn.sockconnect, mode, server, { rpc = true })

  if not ok or channel == 0 then
    vim.notify('term: failed to connect to parent Neovim: ' .. server, vim.log.levels.ERROR)
    return false
  end

  -- Send RPC request to open file in parent, ensuring it opens in a non-terminal window
  -- Use Lua code that finds or creates a non-terminal window
  local lua_code = string.format(
    [[
    local file = %q
    -- Try to find an existing non-terminal window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
      if buftype ~= 'terminal' then
        vim.api.nvim_set_current_win(win)
        vim.cmd('edit ' .. vim.fn.fnameescape(file))
        return
      end
    end
    -- No non-terminal window found, try previous window
    vim.cmd('wincmd p')
    if vim.bo.buftype == 'terminal' then
      -- Still in terminal, create new split
      vim.cmd('new')
    end
    vim.cmd('edit ' .. vim.fn.fnameescape(file))
    ]],
    abs_path
  )
  ok = pcall(vim.fn.rpcrequest, channel, 'nvim_exec_lua', lua_code, {})

  -- Close connection
  pcall(vim.fn.chanclose, channel)

  if not ok then
    vim.notify('term: failed to send edit command to parent Neovim', vim.log.levels.ERROR)
    return false
  end

  return true
end

--- Create a headless nvim wrapper command (like floaterm's EDITOR)
--- This returns a command string that can be used as EDITOR/GIT_EDITOR
---@return string? editor_command nil on failure
function M.create_editor_wrapper()
  -- Get the current nvim executable path
  ---@diagnostic disable-next-line: undefined-field
  local nvim_path = vim.v.progpath
  if not nvim_path or nvim_path == '' then
    vim.notify('term: cannot determine nvim executable path', vim.log.levels.ERROR)
    return nil
  end

  local config_path = vim.fn.stdpath('config')
  if not config_path or config_path == '' then
    vim.notify('term: cannot determine config path', vim.log.levels.ERROR)
    return nil
  end

  -- Build the wrapper command that will be invoked by external tools
  -- This launches a headless nvim that connects back to parent and opens the file
  local wrapper_script = string.format(
    [[%s --headless --clean --noplugin -n -R -c "set runtimepath^=%s" -c "lua require('term.editor-client').open_in_parent(vim.fn.argv()[-1])" -c "qall"]],
    vim.fn.shellescape(nvim_path),
    vim.fn.fnameescape(config_path)
  )

  return wrapper_script
end

return M
