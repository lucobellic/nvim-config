vim.g.limelight_conceal_ctermfg = 'gray'
vim.g.limelight_conceal_guifg = '#1B2733'

local limelight_enabled = false
local function limelight_toggle()
  vim.cmd(limelight_enabled and 'Limelight!' or 'Limelight')
  limelight_enabled = not limelight_enabled
end

vim.api.nvim_create_user_command('LimelightToggle', limelight_toggle, { desc = 'Toggle limelight' })
