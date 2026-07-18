local M = {}

M.CLIENT_ID = 'app_EMoamEEZ73f0CkXaXp7hrann'
M.AUTHORIZE_URL = 'https://auth.openai.com/oauth/authorize'
M.TOKEN_URL = 'https://auth.openai.com/oauth/token'
M.REDIRECT_URI = 'http://localhost:1455/auth/callback'
M.SCOPE = 'openid profile email offline_access'
M.API_BASE_URL = 'https://chatgpt.com/backend-api'
M.TOKEN_FILE_NAME = 'codex_oauth_token.json'
M.CODEX_VERSION = '0.144.5'

---Get the path to the token file for a specific profile
---@param profile? string
---@return string
function M.get_token_path(profile)
  local filename = M.TOKEN_FILE_NAME
  if profile and profile ~= '' then
    filename = filename:gsub('%.json$', '_' .. profile .. '.json')
  end
  return vim.fs.joinpath(vim.fn.stdpath('data'), filename)
end

M.HEADERS = {
  ['OpenAI-Beta'] = 'responses=experimental',
  ['originator'] = 'codex_cli_rs',
  ['User-Agent'] = 'codex-cli/' .. M.CODEX_VERSION,
  ['version'] = M.CODEX_VERSION,
}

--- JWT claim path for ChatGPT account ID
M.JWT_CLAIM_PATH = 'https://api.openai.com/auth'

return M
