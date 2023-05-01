-- Functions to fix current line
local function run_action(action, offse)
  if action.edit or type(action.command) == "table" then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, offse)
    end
    if type(action.command) == "table" then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

local function do_action(action, client)
  if not action.edit
      and client
      and type(client.server_capabilities.code_action) == "table"
      and client.server_capabilities.code_action.resolveProvider
  then
    client.request("codeAction/resolve", action, function(err, real)
      if err then
        return
      end
      if real then
        run_action(real, client.offset_encoding)
      else
        run_action(action, client.offset_encoding)
      end
    end)
  else
    run_action(action, client.offset_encoding)
  end
end

return function()
  local params = vim.lsp.util.make_range_params()   -- get params for current position
  params.context = {
    diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
    only = { "quickfix" }
  }

  local results, err = vim.lsp.buf_request_sync(
    0,                             -- current buffer
    "textDocument/codeAction",     -- get code actions
    params,
    900
  )

  if err then return end

  if not results or vim.tbl_isempty(results) then
    print "No quickfixes!"
    return
  end

  -- we have an action!
  for cid, resp in pairs(results) do
    if resp.result then
      for _, result in pairs(resp.result) do
        -- this is the first action, run it
        do_action(result, vim.lsp.get_client_by_id(cid))
        return
      end
    end
  end

  print "No quickfixes!"
end
