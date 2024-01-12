local EdgyGroups = require('util.edgy.groups')
local edgy_groups = EdgyGroups.new({
  groups = {
    { title = '', pos = 'right', filetypes = { 'Outline' } },
    { title = '', pos = 'right', filetypes = { 'OverseerList' } },
  },
})

-- Commands
local user_command_opts = { nargs = 1, complete = function() return { 'right', 'left', 'top', 'bottom' } end }

vim.api.nvim_create_user_command(
  'EdgyGroupOpen',
  function(opts) edgy_groups:open_group(opts.args, edgy_groups.current_group_index[opts.args]) end,
  user_command_opts
)

vim.api.nvim_create_user_command(
  'EdgyGroupNext',
  function(opts) edgy_groups:open_group(opts.args, 1) end,
  user_command_opts
)

vim.api.nvim_create_user_command(
  'EdgyGroupPrev',
  function(opts) edgy_groups:open_group(opts.args, -1) end,
  user_command_opts
)

vim.api.nvim_create_user_command('EdgyGroupSelect', function()
  vim.ui.select(
    edgy_groups.groups,
    {
      prompt = 'Select Edgy Group:',
      format_item = function(group)
        return group.title .. ': ' .. group.pos .. ' - ' .. table.concat(group.filetypes, ', ')
      end,
      kind = 'edgy.group',
    },
    ---@param group? Edgy.Group
    function(group)
      if group then
        edgy_groups.open_edgebar_views_by_filetypes(group.pos, group.filetypes)
      end
    end
  )
end, {})

-- Keymaps

vim.keymap.set(
  'n',
  '<leader>el',
  function() vim.cmd('EdgyGroupNext right') end,
  { desc = 'Edgy Group Next Right', repeatable = true }
)
vim.keymap.set(
  'n',
  '<leader>eh',
  function() vim.cmd('EdgyGroupPrev right') end,
  { desc = 'Edgy Group Next Right', repeatable = true }
)

return edgy_groups
