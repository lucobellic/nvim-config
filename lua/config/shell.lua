---@class ShellConfig
---@field shell string Shell executable
---@field shellpipe? string How to pipe output
---@field shellcmdflag string Flag to pass a command string to the shell
---@field shellquote? string Quoting character for the shell command
---@field shellxquote? string Extra quoting for the shell command
---@field interactive_login_flag string Flag(s) to launch the shell as interactive+login (used by e.g. overseer to replicate a terminal environment)

---@type table<string, ShellConfig>
local shells = {
  fish = {
    shell = 'fish',
    shellpipe = '|',
    shellcmdflag = '-c',
    interactive_login_flag = '-lic',
  },
  zsh = {
    shell = 'zsh',
    shellpipe = '|',
    shellcmdflag = '-c',
    interactive_login_flag = '-ilc',
  },
  bash = {
    shell = 'bash',
    shellcmdflag = '-c',
    interactive_login_flag = '-ilc',
  },
  pwsh = {
    shell = 'pwsh',
    shellcmdflag = '-c',
    shellquote = '"',
    shellxquote = '',
    interactive_login_flag = '-c', -- pwsh has no login/interactive distinction
  },
  sh = {
    shell = 'sh',
    shellcmdflag = '-c',
    interactive_login_flag = '-c',
  },
}

local active ---@type ShellConfig

if not os.getenv('INSIDE_DOCKER') and vim.fn.executable('fish') == 1 then
  active = shells.fish
elseif vim.fn.executable('zsh') == 1 then
  active = shells.zsh
elseif vim.fn.executable('pwsh') == 1 then
  active = shells.pwsh
elseif vim.fn.executable('bash') == 1 then
  active = shells.bash
else
  active = shells.sh
end

vim.o.shell = active.shell
vim.o.shellcmdflag = active.shellcmdflag
if active.shellpipe then
  vim.o.shellpipe = active.shellpipe
end
if active.shellquote then
  vim.o.shellquote = active.shellquote
end
if active.shellxquote then
  vim.o.shellxquote = active.shellxquote
end

-- Expose the active config for other modules (e.g. overseer components)
vim.g.shell_config = active
