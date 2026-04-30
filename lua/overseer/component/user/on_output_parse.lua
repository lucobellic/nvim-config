local files = require('overseer.files')
local log = require('overseer.log')
local problem_matcher = require('overseer.vscode.problem_matcher')
local user_util = require('overseer.component.user.util')

---@param cwd string
---@param result table
---@return table
local function fix_relative_filenames(cwd, result)
  if result.diagnostics then
    -- Ensure that all relative filenames are rooted at the task cwd, not vim's current cwd
    for _, diag in ipairs(result.diagnostics) do
      if diag.filename and not files.is_absolute(diag.filename) then
        diag.filename = vim.fs.joinpath(cwd, diag.filename)
      end
    end
  end
  return result
end

---@type overseer.ComponentFileDefinition
local comp = {
  desc = 'Parses task output and sets task result',
  params = {
    parser = {
      desc = 'Parser definition to extract values from output',
      type = 'opaque',
      optional = true,
      order = 1,
    },
    problem_matcher = {
      desc = 'VS Code-style problem matcher',
      type = 'opaque',
      optional = true,
      order = 2,
    },
    relative_file_root = {
      desc = 'Relative filepaths will be joined to this root (instead of task cwd)',
      optional = true,
      default_from_task = true,
      order = 3,
    },
    precalculated_vars = {
      desc = 'Precalculated VS Code task variables',
      long_desc = "Tasks that are started from the VS Code provider precalculate certain interpolated variables (e.g. ${workspaceFolder}). We pass those in as params so they will remain stable even if Neovim's state changes in between creating and running (or restarting) the task.",
      type = 'opaque',
      optional = true,
      order = 4,
    },
  },
  constructor = function(params)
    ---@type overseer.OutputParser|nil
    local parser = nil
    local version = 0

    return {
      on_init = function(self, task)
        if params.parser and params.problem_matcher then
          log:warn("on_output_parse: cannot specify both 'parser' and 'problem_matcher'")
        end

        -- Extract command in one line and display it in the notification
        ---@diagnostic disable-next-line: param-type-mismatch
        local command_line = type(task.cmd) == 'string' and task.cmd or table.concat(task.cmd, ' ') or ''

        local pm = user_util.get_problem_matcher(command_line, params)
        if pm then
          parser = problem_matcher.get_parser_from_problem_matcher(pm, params.precalculated_vars)
        elseif params.parser then
          -- Allow passing a pre-built OutputParser directly
          parser = params.parser
        end

        if parser then
          version = parser.result_version or 0
        end
      end,
      on_reset = function(self)
        if parser then
          parser:reset()
          version = parser.result_version or 0
        end
      end,
      on_output_lines = function(self, task, lines)
        if not parser then
          return
        end
        for _, line in ipairs(lines) do
          parser:parse(line)
        end
        local new_version = parser.result_version or 0
        if new_version ~= version then
          version = new_version
          task:set_result(fix_relative_filenames(params.relative_file_root or task.cwd, parser:get_result()))
        end
      end,
      on_pre_result = function(self, task)
        if not parser then
          return {}
        end
        return fix_relative_filenames(params.relative_file_root or task.cwd, parser:get_result())
      end,
    }
  end,
}

return comp
