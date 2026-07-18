local config = require('codecompanion.config')
local constants = require('plugins.ai.codecompanion.adapters.http.codex.constants')
local curl = require('plenary.curl')
local log = require('codecompanion.utils.log')

local M = {}

local is_authenticating = false
local uv = vim.uv or vim.loop

-- =============================================================================
-- TOKEN PERSISTENCE
-- =============================================================================

---Load credentials from disk
---@param token_file string
---@return string|nil refresh_token
---@return string|nil account_id (cached chatgpt_account_id)
function M.load_token(token_file)
  local file = io.open(token_file, 'r')
  if file then
    local content = file:read('*a')
    file:close()
    local ok, data = pcall(vim.json.decode, content)
    if ok and data.refresh_token then
      return data.refresh_token, data.chatgpt_account_id
    end
  end
  return nil, nil
end

---Save token data to disk (merge with existing)
---@param token_file string
---@param data table
---@return boolean
function M.save_token(token_file, data) -- changed from local function to M.
  local existing = {}
  local rfile = io.open(token_file, 'r')
  if rfile then
    local content = rfile:read('*a')
    rfile:close()
    local ok, json = pcall(vim.json.decode, content)
    if ok then
      existing = json
    end
  end

  local final_data = vim.tbl_extend('force', existing, data)
  local fd, open_err = uv.fs_open(token_file, 'w', 384)
  if not fd then
    log:error('Codex: Failed to open token file: %s', open_err)
    return false
  end

  local _, chmod_err = uv.fs_fchmod(fd, 384)
  if chmod_err then
    uv.fs_close(fd)
    log:error('Codex: Failed to secure token file permissions: %s', chmod_err)
    return false
  end

  local content = vim.json.encode(final_data)
  local _, write_err = uv.fs_write(fd, content, 0)
  local _, close_err = uv.fs_close(fd)
  if write_err or close_err then
    log:error('Codex: Failed to save token: %s', write_err or close_err)
    return false
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
---@param token string
---@return table|nil
function M.decode_jwt(token)
  local parts = vim.split(token, '.', { plain = true })
  if #parts ~= 3 then
    return nil
  end
  local payload_str = base64url_decode(parts[2])
  local ok, payload = pcall(vim.json.decode, payload_str)
  if ok then
    return payload
  end
  return nil
end

---Extract the ChatGPT account ID from an access token
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
---@return string verifier
---@return string challenge
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
local function exchange_code(token_file, code, verifier, redirect_uri)
  local body_str = string.format(
    'grant_type=authorization_code&client_id=%s&code=%s&code_verifier=%s&redirect_uri=%s',
    vim.uri_encode(constants.CLIENT_ID),
    vim.uri_encode(code),
    vim.uri_encode(verifier),
    vim.uri_encode(redirect_uri)
  )

  local status, response = pcall(curl.post, constants.TOKEN_URL, {
    insecure = config.adapters
      and config.adapters.http
      and config.adapters.http.opts
      and config.adapters.http.opts.allow_insecure,
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

---Start the OAuth2 PKCE flow with a local server
---@param token_file string
function M.authenticate(token_file)
  if is_authenticating then
    vim.notify('Codex: Authentication process already in progress.', vim.log.levels.WARN)
    return
  end
  is_authenticating = true

  -- Timeout to reset the flag
  vim.defer_fn(function() is_authenticating = false end, 120000) -- 2 minutes

  local server = uv.new_tcp()
  local host = '127.0.0.1'
  local port = 1455 -- Must match REDIRECT_URI

  local ok_bind, bind_err = pcall(function() server:bind(host, port) end)
  if not ok_bind then
    log:error('Codex: Failed to bind to port %d: %s', port, tostring(bind_err))
    vim.notify(
      string.format('Codex: Port %d is already in use. Close any other auth flow and try again.', port),
      vim.log.levels.ERROR
    )
    is_authenticating = false
    return
  end

  local verifier, challenge, random_err = M.generate_pkce()
  local state, state_err = uv.random(16)
  if not verifier or not state then
    server:close()
    vim.notify(
      'Codex: Failed to generate secure OAuth credentials: ' .. tostring(random_err or state_err),
      vim.log.levels.ERROR
    )
    is_authenticating = false
    return
  end
  state = base64url_encode(state)

  server:listen(128, function(err)
    assert(not err, err)
    local client = uv.new_tcp()
    server:accept(client)

    client:read_start(function(read_err, chunk)
      if chunk then
        -- Parse the request path
        local request_path = chunk:match('GET ([^ ]+)')
        if not request_path or not request_path:find('/auth/callback') then
          local body_404 = 'Not found'
          local resp_404 = 'HTTP/1.1 404 Not Found\r\n'
            .. 'Content-Type: text/plain\r\n'
            .. 'Content-Length: '
            .. #body_404
            .. '\r\n'
            .. 'Connection: close\r\n\r\n'
            .. body_404
          client:write(resp_404, function()
            client:shutdown()
            client:close()
          end)
          return
        end

        local code = request_path:match('code=([^& ]+)')
        local received_state = request_path:match('state=([^& ]+)')

        local response_body
        if code and received_state == state then
          response_body = '<h1>Authentication Successful</h1>'
            .. '<p>You can close this window and return to Neovim.</p>'
            .. '<script>window.close()</script>'
          vim.schedule(function()
            exchange_code(token_file, code, verifier, constants.REDIRECT_URI)
            is_authenticating = false
          end)
        else
          response_body = '<h1>Error</h1><p>Could not obtain code or invalid state.</p>'
          is_authenticating = false
        end

        local response = 'HTTP/1.1 200 OK\r\n'
          .. 'Content-Type: text/html\r\n'
          .. 'Content-Length: '
          .. #response_body
          .. '\r\n'
          .. 'Connection: close\r\n\r\n'
          .. response_body

        client:write(response, function()
          client:shutdown()
          client:close()
          server:close()
        end)
      end
    end)
  end)

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
  vim.ui.open(url)
end

-- =============================================================================
-- TOKEN REFRESH
-- =============================================================================

---Refresh the access token using the refresh token
---@param refresh_token string
---@return table|nil {access_token, refresh_token, expires_in}
function M.refresh_access_token(refresh_token)
  local body_str = string.format(
    'grant_type=refresh_token&refresh_token=%s&client_id=%s',
    vim.uri_encode(refresh_token),
    vim.uri_encode(constants.CLIENT_ID)
  )

  local ok, response = pcall(curl.post, constants.TOKEN_URL, {
    insecure = config.adapters
      and config.adapters.http
      and config.adapters.http.opts
      and config.adapters.http.opts.allow_insecure,
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
