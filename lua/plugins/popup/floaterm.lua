local function floaterm_toogle(params)
  local tool_name = params.args
  local tool_title = tool_name:gsub("^%l", string.upper)
  local bufnr = vim.api.nvim_call_function('floaterm#terminal#get_bufnr', { tool_name })
  if bufnr == -1 then
    local format = string.format(
      '--height=0.8 --width=0.8 --title=%s\\ $1/$2 --name=%s %s',
      tool_title,
      tool_name,
      tool_name
    )
    vim.api.nvim_call_function('floaterm#run', { 'new', tool_name, { 'v', 0, 0, 0 }, format })
  else
    vim.api.nvim_call_function('floaterm#toggle', { 0, bufnr, '' })
  end
end

return {
  'lucobellic/vim-floaterm',
  event = 'VeryLazy',
  branch = 'personal',
  dependencies = { 'MunifTanjim/nui.nvim' },
  keys = {
    { '<leader>er', ':ToggleTool ranger<cr>',         desc = 'Ranger' },
    { '<leader>g;', ':ToggleTool lazygit<cr>',        desc = 'Lazygit' },
    { '<F7>',       ':FloatermToggle<cr>',            mode = 'n',      desc = 'Toggle Floaterm' },
    { '<F7>',       '<C-\\><C-n>:FloatermToggle<cr>', mode = 't',      desc = 'Toggle Floaterm' },
  },
  init = function()
    vim.g.floaterm_shell = vim.o.shell
    vim.g.floaterm_autoclose = 1 -- Close only if the job exits normally
    vim.g.floaterm_autohide = 1
    vim.g.floaterm_borderchars = '─│─│╭╮╯╰'
    vim.g.floaterm_autoinsert = true
    vim.g.floaterm_titleposition = 'center'
    vim.g.floaterm_title = 'Terminal $1/$2'

    vim.api.nvim_create_user_command('ToggleTool', floaterm_toogle, { nargs = 1, count = 1 })
  end
}
