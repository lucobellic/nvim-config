local auth_page = require('plugins.ai.codecompanion.adapters.http.codex.auth_page')
local config = require('codecompanion.config')
local constants = require('plugins.ai.codecompanion.adapters.http.codex.constants')
local curl = require('plenary.curl')
local log = require('codecompanion.utils.log')

---@class Codex.Auth
local M = {}

---@class Codex.TokenData
---@field access_token? string
---@field refresh_token? string
---@field expires_in? integer
---@field chatgpt_account_id? string

local is_authenticating = false
local uv = vim.uv or vim.loop

-- =============================================================================
-- TOKEN PERSISTENCE
-- =============================================================================

---Load credentials from disk
---@public
---@param token_file string
---@return string|nil refresh_token
---@return string|nil account_id (cached chatgpt_account_id)
function M.load_token(token_file)
  local file = io.open(token_file, 'r')
  if file then
    local content = file:read('*a')
    file:close()
    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == 'table' and data.refresh_token then
      return data.refresh_token, data.chatgpt_account_id
    end
  end
  return nil, nil
end

---Save the credentials required for token refresh.
---@public
---@param token_file string
---@param data Codex.TokenData
---@return boolean
function M.save_token(token_file, data)
  local existing = {}
  local rfile = io.open(token_file, 'r')
  if rfile then
    local content = rfile:read('*a')
    rfile:close()
    local ok, json = pcall(vim.json.decode, content)
    if ok and type(json) == 'table' then
      existing = json
    end
  end

  local final_data = {
    refresh_token = data.refresh_token or existing.refresh_token,
    chatgpt_account_id = data.chatgpt_account_id or existing.chatgpt_account_id,
  }
  if not final_data.refresh_token then
    log:error('Codex: Refusing to save credentials without a refresh token')
    return false
  end

  local temporary_file = token_file .. '.tmp.' .. tostring(uv.hrtime())
  local fd, open_err = uv.fs_open(temporary_file, 'wx', 384)
  if not fd then
    log:error('Codex: Failed to open token file: %s', open_err)
    return false
  end

  local _, chmod_err = uv.fs_fchmod(fd, 384)
  if chmod_err then
    uv.fs_close(fd)
    uv.fs_unlink(temporary_file)
    log:error('Codex: Failed to secure token file permissions: %s', chmod_err)
    return false
  end

  local content = vim.json.encode(final_data)
  local offset = 0
  local write_err
  while offset < #content do
    local written
    written, write_err = uv.fs_write(fd, content:sub(offset + 1), offset)
    if not written or written == 0 then
      break
    end
    offset = offset + written
  end
  local _, sync_err = uv.fs_fsync(fd)
  local _, close_err = uv.fs_close(fd)
  if offset ~= #content or write_err or sync_err or close_err then
    uv.fs_unlink(temporary_file)
    log:error('Codex: Failed to save token: %s', write_err or sync_err or close_err or 'incomplete write')
    return false
  end

  local _, rename_err = uv.fs_rename(temporary_file, token_file)
  if rename_err then
    uv.fs_unlink(temporary_file)
    log:error('Codex: Failed to replace token file: %s', rename_err)
    return false
  end

  local directory_fd, directory_open_err = uv.fs_open(vim.fs.dirname(token_file), 'r', 0)
  if directory_fd then
    local _, directory_sync_err = uv.fs_fsync(directory_fd)
    local _, directory_close_err = uv.fs_close(directory_fd)
    if directory_sync_err or directory_close_err then
      log:warn('Codex: Failed to sync the token directory: %s', directory_sync_err or directory_close_err)
    end
  else
    log:warn('Codex: Failed to open the token directory for syncing: %s', directory_open_err)
  end

  return true
end

-- =============================================================================
-- JWT DECODING
-- =============================================================================

---Base64url decode (no padding)
---@param input string
---@return string
local function base64url_decode(input)
  local b64 = input:gsub('-', '+'):gsub('_', '/')
  local pad = #b64 % 4
  if pad > 0 then
    b64 = b64 .. string.rep('=', 4 - pad)
  end
  return vim.base64.decode(b64)
end

---Decode a JWT token to extract the payload
---@public
---@param token string
---@return table|nil
function M.decode_jwt(token)
  local parts = vim.split(token, '.', { plain = true })
  if #parts ~= 3 then
    return nil
  end
  local ok, payload = pcall(function() return vim.json.decode(base64url_decode(parts[2])) end)
  if ok and type(payload) == 'table' then
    return payload
  end
  return nil
end

---Extract the ChatGPT account ID from an access token
---@public
---@param access_token string
---@return string|nil
function M.extract_account_id(access_token)
  local payload = M.decode_jwt(access_token)
  if payload then
    local auth_claim = payload[constants.JWT_CLAIM_PATH]
    if auth_claim and auth_claim.chatgpt_account_id then
      return auth_claim.chatgpt_account_id
    end
  end
  return nil
end

-- =============================================================================
-- PKCE
-- =============================================================================

---Base64url encode (no padding)
---@param data string raw binary data
---@return string
local function base64url_encode(data) return vim.base64.encode(data):gsub('+', '-'):gsub('/', '_'):gsub('=', '') end

---Generate PKCE code_verifier and code_challenge (S256)
---@public
---@return string? verifier
---@return string? challenge
---@return string? error
function M.generate_pkce()
  -- code_verifier: 43-128 unreserved characters
  local random, err = uv.random(32)
  if not random then
    return nil, nil, err
  end
  local verifier = base64url_encode(random)

  -- code_challenge: BASE64URL(SHA256(verifier))
  -- Use vim.fn.sha256() which is built into Neovim (no external deps)
  local hex_hash = vim.fn.sha256(verifier)

  -- Convert hex string to raw bytes
  local raw = ''
  for i = 1, #hex_hash, 2 do
    raw = raw .. string.char(tonumber(hex_hash:sub(i, i + 1), 16))
  end

  local challenge = base64url_encode(raw)
  return verifier, challenge
end

-- =============================================================================
-- TOKEN EXCHANGE
-- =============================================================================

---Exchange authorization code for tokens
---@param token_file string
---@param code string
---@param verifier string PKCE code_verifier
---@param redirect_uri string
---@return Codex.TokenData|nil
local function exchange_code(token_file, code, verifier, redirect_uri)
  local body_str = string.format(
    'grant_type=authorization_code&client_id=%s&code=%s&code_verifier=%s&redirect_uri=%s',
    vim.uri_encode(constants.CLIENT_ID),
    vim.uri_encode(code),
    vim.uri_encode(verifier),
    vim.uri_encode(redirect_uri)
  )

  local status, response = pcall(curl.post, constants.TOKEN_URL, {
    proxy = config.adapters and config.adapters.http and config.adapters.http.opts and config.adapters.http.opts.proxy,
    headers = {
      ['Content-Type'] = 'application/x-www-form-urlencoded',
    },
    raw_body = body_str,
    timeout = 10000,
  })

  if not status then
    vim.notify('Codex: error in curl request: ' .. tostring(response), vim.log.levels.ERROR)
    return nil
  end

  if response.status == 200 then
    local ok, data = pcall(vim.json.decode, response.body)
    if not ok then
      vim.notify('Codex: error parsing token response: ' .. tostring(data), vim.log.levels.ERROR)
      return nil
    end

    -- Extract and cache the account ID from the access token
    if data.access_token then
      local account_id = M.extract_account_id(data.access_token)
      if account_id then
        data.chatgpt_account_id = account_id
      end
    end

    if M.save_token(token_file, data) then
      vim.notify('Codex: Authentication successful!', vim.log.levels.INFO)
      return data
    end
  else
    vim.notify('Codex: error exchanging code: ' .. tostring(response.body), vim.log.levels.ERROR)
  end
  return nil
end

-- =============================================================================
-- OAUTH FLOW
-- =============================================================================

---@param handle userdata|nil
---@return nil
local function close_handle(handle)
  if handle and not handle:is_closing() then
    handle:close()
  end
end

---@param value string
---@return string
local function decode_query_value(value)
  return (value:gsub('+', ' '):gsub('%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end))
end

---@param request_path string
---@return string path
---@return table<string, string> query
local function parse_request_path(request_path)
  local path, query_string = request_path:match('^([^?]*)%??(.*)$')
  local query = {}
  for key, value in query_string:gmatch('([^&=]+)=([^&]*)') do
    query[decode_query_value(key)] = decode_query_value(value)
  end
  return path, query
end

---@param client userdata
---@param status integer
---@param reason string
---@param content_type string
---@param body string
---@param callback? fun()
---@return nil
local function send_response(client, status, reason, content_type, body, callback)
  local response = string.format(
    'HTTP/1.1 %d %s\r\nContent-Type: %s\r\nCache-Control: no-store\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s',
    status,
    reason,
    content_type,
    #body,
    body
  )

  client:write(response, function(write_err)
    if write_err then
      log:error('Codex: Failed to write authentication response: %s', write_err)
    end
    close_handle(client)
    if callback then
      vim.schedule(callback)
    end
  end)
end

---Start the OAuth2 PKCE flow with a local server
---@public
---@param token_file string
---@return nil
function M.authenticate(token_file)
  if is_authenticating then
    vim.notify('Codex: Authentication process already in progress.', vim.log.levels.WARN)
    return
  end
  is_authenticating = true

  local server = uv.new_tcp()
  if not server then
    vim.notify('Codex: Failed to create the authentication server.', vim.log.levels.ERROR)
    is_authenticating = false
    return
  end

  local host = '127.0.0.1'
  local port = 1455 -- Must match REDIRECT_URI
  local timer = uv.new_timer()
  local callback_handled = false
  local active_clients = {}
  local active_client_count = 0
  local client_timers = {}

  ---@param client userdata
  ---@return nil
  local function stop_client_timer(client)
    local client_timer = client_timers[client]
    if client_timer then
      client_timers[client] = nil
      close_handle(client_timer)
    end
  end

  ---@param client userdata
  ---@return nil
  local function close_client(client)
    if active_clients[client] then
      active_clients[client] = nil
      active_client_count = active_client_count - 1
    end
    stop_client_timer(client)
    close_handle(client)
  end

  local function finish_authentication()
    is_authenticating = false
    for client in pairs(active_clients) do
      close_client(client)
    end
    close_handle(server)
    if timer and not timer:is_closing() then
      timer:stop()
      timer:close()
    end
  end

  if not timer then
    finish_authentication()
    vim.notify('Codex: Failed to create the authentication timer.', vim.log.levels.ERROR)
    return
  end

  timer:start(120000, 0, function()
    finish_authentication()
    vim.schedule(function() vim.notify('Codex: Authentication timed out. Please try again.', vim.log.levels.WARN) end)
  end)

  local ok_bind, bind_result, bind_err = pcall(server.bind, server, host, port)
  if not ok_bind or not bind_result then
    log:error('Codex: Failed to bind to port %d: %s', port, tostring(bind_err or bind_result))
    finish_authentication()
    vim.notify(
      string.format('Codex: Port %d is already in use. Close any other auth flow and try again.', port),
      vim.log.levels.ERROR
    )
    return
  end

  local verifier, challenge, random_err = M.generate_pkce()
  local state, state_err = uv.random(16)
  if not verifier or not state then
    finish_authentication()
    vim.notify(
      'Codex: Failed to generate secure OAuth credentials: ' .. tostring(random_err or state_err),
      vim.log.levels.ERROR
    )
    return
  end
  state = base64url_encode(state)

  local ok_listen, listen_result, listen_err = pcall(server.listen, server, 128, function(err)
    if err then
      log:error('Codex: Authentication listener error: %s', err)
      finish_authentication()
      vim.schedule(function() vim.notify('Codex: Authentication listener failed.', vim.log.levels.ERROR) end)
      return
    end

    local client = uv.new_tcp()
    if not client then
      log:error('Codex: Failed to create an authentication client socket')
      return
    end

    local accepted, accept_err = server:accept(client)
    if not accepted then
      log:error('Codex: Failed to accept authentication callback: %s', accept_err)
      close_handle(client)
      return
    end

    if active_client_count >= 8 then
      close_handle(client)
      return
    end

    local client_timer = uv.new_timer()
    if not client_timer then
      close_handle(client)
      return
    end
    active_clients[client] = true
    active_client_count = active_client_count + 1
    client_timers[client] = client_timer
    client_timer:start(10000, 0, function() close_client(client) end)

    local request = ''

    ---@param status integer
    ---@param reason string
    ---@param content_type string
    ---@param body string
    ---@param callback? fun()
    ---@return nil
    local function respond(status, reason, content_type, body, callback)
      send_response(client, status, reason, content_type, body, function()
        close_client(client)
        if callback then
          callback()
        end
      end)
    end

    client:read_start(function(read_err, chunk)
      if read_err then
        log:error('Codex: Failed to read authentication callback: %s', read_err)
        close_client(client)
        return
      end

      if not chunk then
        close_client(client)
        return
      end

      request = request .. chunk
      if #request > 8192 then
        client:read_stop()
        respond(413, 'Content Too Large', 'text/plain', 'Request too large')
        return
      end

      if not request:find('\r\n\r\n', 1, true) then
        return
      end

      client:read_stop()
      stop_client_timer(client)
      local method, request_path = request:match('^(%S+) (%S+) HTTP/%d%.%d\r\n')
      if method ~= 'GET' or not request_path then
        respond(400, 'Bad Request', 'text/plain', 'Invalid request')
        return
      end

      local path, query = parse_request_path(request_path)
      if path ~= '/auth/callback' then
        respond(404, 'Not Found', 'text/plain', 'Not found')
        return
      end

      if callback_handled then
        respond(409, 'Conflict', 'text/plain', 'Authentication callback already received')
        return
      end

      if query.state ~= state then
        local response_body = auth_page.error('The OAuth state was invalid.')
        respond(400, 'Bad Request', 'text/html; charset=utf-8', response_body)
        return
      end

      callback_handled = true
      close_handle(server)

      if not query.code then
        local detail = query.error_description or query.error or 'The authorization code was missing.'
        local response_body = auth_page.error(detail)
        respond(400, 'Bad Request', 'text/html; charset=utf-8', response_body, finish_authentication)
        return
      end

      vim.schedule(function()
        local data = exchange_code(token_file, query.code, verifier, constants.REDIRECT_URI)
        local response_body
        local status
        local reason
        if data then
          response_body = auth_page.success()
          status = 200
          reason = 'OK'
        else
          response_body = auth_page.error('The authorization code could not be exchanged for credentials.')
          status = 502
          reason = 'Bad Gateway'
        end
        respond(status, reason, 'text/html; charset=utf-8', response_body, finish_authentication)
      end)
    end)
  end)

  if not ok_listen or not listen_result then
    log:error('Codex: Failed to listen on port %d: %s', port, tostring(listen_err or listen_result))
    finish_authentication()
    vim.notify('Codex: Failed to start the authentication server.', vim.log.levels.ERROR)
    return
  end

  -- Build the auth URL with PKCE
  local url = string.format(
    '%s?response_type=code&client_id=%s&redirect_uri=%s&scope=%s&code_challenge=%s&code_challenge_method=S256&state=%s&id_token_add_organizations=true&codex_cli_simplified_flow=true&originator=codex_cli_rs',
    constants.AUTHORIZE_URL,
    vim.uri_encode(constants.CLIENT_ID),
    vim.uri_encode(constants.REDIRECT_URI),
    vim.uri_encode(constants.SCOPE),
    vim.uri_encode(challenge),
    vim.uri_encode(state)
  )

  vim.notify('Codex: Opening browser for authentication...', vim.log.levels.INFO)
  local _, open_err = vim.ui.open(url)
  if open_err then
    finish_authentication()
    vim.notify('Codex: Failed to open the authentication page: ' .. open_err, vim.log.levels.ERROR)
  end
end

-- =============================================================================
-- TOKEN REFRESH
-- =============================================================================

---Refresh the access token using the refresh token
---@public
---@param refresh_token string
---@return Codex.TokenData|nil
function M.refresh_access_token(refresh_token)
  local body_str = string.format(
    'grant_type=refresh_token&refresh_token=%s&client_id=%s',
    vim.uri_encode(refresh_token),
    vim.uri_encode(constants.CLIENT_ID)
  )

  local ok, response = pcall(curl.post, constants.TOKEN_URL, {
    proxy = config.adapters and config.adapters.http and config.adapters.http.opts and config.adapters.http.opts.proxy,
    headers = {
      ['Content-Type'] = 'application/x-www-form-urlencoded',
    },
    raw_body = body_str,
    timeout = 10000,
  })

  if not ok then
    log:error('Codex: Network error during token refresh: %s', response)
    return nil
  end

  if response.status == 200 then
    local decode_ok, data = pcall(vim.json.decode, response.body)
    if decode_ok and data and data.access_token then
      return data
    else
      log:error('Codex: Failed to decode token refresh response: %s', response.body)
    end
  else
    log:error('Codex: Token refresh failed (Status %s): %s', response.status, response.body)
  end

  return nil
end

return M
