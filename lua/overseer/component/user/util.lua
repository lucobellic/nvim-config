local matcher = require('overseer.template.vscode.problem_matcher')

local M = {}

M.python_problem_matcher = {
  owner = 'python',
  fileLocation = 'absolute',
  pattern = {
    {
      vim_regexp = '\\v^.*File "([^"]|.*)", line (\\d+).*',
      file = 1,
      line = 2,
    },
    {
      regexp = '(.*)',
      code = 1,
    },
    {
      vim_regexp = '\\v(.*)',
      message = 1,
    },
  },
}

---@class CommandProblemMatcher
---@field regexp string regex to match on the command
---@field problem_matcher table problem matcher
local command_problem_matcher = {
  {
    regexp = '\\(cmake\\|reach\\).*build',
    problem_matcher = matcher.resolve_problem_matcher('$gcc'),
  },
  {
    regexp = '\\(py\\|conf-test\\)',
    problem_matcher = M.python_problem_matcher,
  },
}

---@param cmd string?
---@return overseer.Parser?
function M.get_problem_matcher_from_cmd(cmd)
  if cmd ~= nil then
    for _, cmd_matcher in ipairs(command_problem_matcher) do
      if vim.fn.matchstr(cmd, cmd_matcher.regexp) ~= '' then
        return cmd_matcher.problem_matcher
      end
    end
  end
end

---Get problem matcher from parameters or from command if not provided
---@param cmd string?
---@param params overseer.Params?
---@return table|nil problem_matcher
function M.get_problem_matcher(cmd, params)
  local problem_matcher = nil

  if params and params.problem_matcher then
    problem_matcher = matcher.resolve_problem_matcher(params.problem_matcher)
  end

  if problem_matcher == nil then
    problem_matcher = M.get_problem_matcher_from_cmd(cmd)
  end

  return problem_matcher
end

return M
