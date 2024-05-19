local function incline_safe_refresh()
  local ok, incline = pcall(require, 'incline')
  if ok then
    incline.refresh()
  end
end

return {
  {
    'lucobellic/edgy-group.nvim',
    dependencies = { 'folke/edgy.nvim' },
    keys = {
      {
        '<leader>;',
        function()
          require('edgy-group.stl').pick()
          incline_safe_refresh()
        end,
        desc = 'Edgy Group Pick',
      },
      {
        '<c-;>',
        function()
          require('edgy-group.stl').pick()
          incline_safe_refresh()
        end,
        desc = 'Edgy Group Pick',
      },
    },
    opts = {
      groups = {
        right = {
          { icon = '', titles = { 'trouble-symbols' }, pick_key = 'o' },
          { icon = '󰙨', titles = { 'neotest-summary' }, pick_key = 't' },
          { icon = '', titles = { 'copilot-chat' }, pick_key = 'c' },
        },
        bottom = {
          { icon = '', titles = { 'toggleterm', 'toggleterm-tasks', 'overseer' }, pick_key = 'p' },
          { icon = '', titles = { 'trouble-diagnostics', 'trouble-qflist' }, pick_key = 'x' },
          { icon = '', titles = { 'trouble-telescope' }, pick_key = 's' },
          { icon = '', titles = { 'trouble-lsp-references', 'trouble-lsp-definitions' }, pick_key = 'r' },
          { icon = '', titles = { 'noice' }, pick_key = 'n' },
          { icon = '󰙨', titles = { 'neotest-panel' }, pick_key = 't' },
        },
      },
      statusline = {
        clickable = true,
        colored = true,
        colors = {
          active = 'Identifier',
          inactive = 'Directory',
          pick_active = 'FlashLabel',
          pick_inactive = 'FlashLabel',
        },
        pick_key_pose = 'right_separator',
        pick_function = function(key)
          -- Use upper case to focus all element of the selected group while closing other (disable toggle)
          local toggle = not key:match('%u')
          local edgy_group = require('edgy-group')
          for _, group in ipairs(edgy_group.get_groups_by_key(key:lower())) do
            pcall(edgy_group.open_group_index, group.position, group.index, toggle)
          end
        end,
      },
    },
  },
}
