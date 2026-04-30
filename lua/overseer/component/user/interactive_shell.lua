--- Component that wraps tasks in an interactive login shell.
--- This ensures the task gets the same environment as a terminal window:
--- full PATH, fish interactive config (e.g. ~/.local/bin prepended), aliases, etc.
---
--- Background: overseer passes table commands directly to jobstart(), bypassing
--- vim.o.shell and vim.o.shellcmdflag entirely. This component rewrites task.cmd
--- to explicitly invoke the user's shell interactive login flag
--- so the shell sources its full config before running the command.
---@type overseer.ComponentFileDefinition
return {
  desc = 'Run task in an interactive login shell (same environment as a terminal window)',
  constructor = function()
    return {
      on_pre_start = function(_, task)
        -- Normalize cmd to a single string so we can pass it to the shell
        local cmd_str = type(task.cmd) == 'table'
            and table.concat(vim.tbl_map(function(arg) return vim.fn.shellescape(tostring(arg)) end, task.cmd), ' ')
          or tostring(task.cmd)

        -- Use the interactive+login flag defined in lua/config/shell.lua for the active shell
        local shell_config = vim.g.shell_config
        task.cmd = { shell_config.shell, shell_config.interactive_login_flag, cmd_str }
      end,
    }
  end,
}
