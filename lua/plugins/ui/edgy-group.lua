if vim.g.vscode then
  local vscode = require('vscode')
  vim.keymap.set(
    { 'n' },
    '<leader>;d',
    function() vscode.action('workbench.view.debug') end,
    { repeatable = true, desc = 'Toggle Debug View' }
  )
end

local function incline_safe_refresh()
  local ok, incline = pcall(require, 'incline')
  if ok then
    incline.refresh()
    vim.defer_fn(function() incline.refresh() end, 200)
    vim.defer_fn(function() incline.refresh() end, 400)
  end
end

return {
  {
    'lucobellic/edgy-group.nvim',
    dependencies = { 'folke/edgy.nvim' },
    dev = true,
    keys = {
      {
        '<leader>;',
        function() require('edgy-group.stl').pick() end,
        desc = 'Edgy Group Pick',
        mode = { 'n', 'v' },
      },
      {
        '<c-;>',
        function() require('edgy-group.stl').pick() end,
        desc = 'Edgy Group Pick',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      groups = {
        left = {
          { icon = '', titles = { 'Neo-Tree Buffers', 'Neo-Tree', 'trouble-symbols' }, pick_key = 'e' },
          { icon = '', titles = { 'diffview-file-panel' }, pick_key = 'i' },
          { icon = '', titles = { 'dapui_scopes', 'dapui_watches' }, pick_key = 'd' },
        },
        right = {
          { icon = '', titles = { 'codecompanion' }, pick_key = 'a' },
          { icon = '', titles = { 'opencode' }, pick_key = 'o' },
          { icon = '', titles = { 'cursor-agent' }, pick_key = 'c' },
          { icon = '󰊭', titles = { 'gemini' }, pick_key = 'g' },
          { icon = '', titles = { 'neotest-summary' }, pick_key = 't' },
          { icon = '', titles = { 'dapui_stacks', 'dapui_breakpoints' }, pick_key = 'd' },
        },
        bottom = {
          { icon = '', titles = { 'toggleterm', 'toggleterm-tasks', 'overseer' }, pick_key = 'p' },
          { icon = '', titles = { 'trouble-qflist', 'trouble-diagnostics' }, pick_key = 'x' },
          { icon = '', titles = { 'trouble-snacks', 'trouble-snacks-files' }, pick_key = 's' },
          { icon = '', titles = { 'trouble-lsp-references', 'trouble-lsp-definitions' }, pick_key = 'r' },
          { icon = '', titles = { 'trouble-lsp-references', 'trouble-in-out', 'trouble-lsp' }, pick_key = 'l' },
          { icon = '', titles = { 'noice' }, pick_key = 'n' },
          { icon = '', titles = { 'neotest-panel' }, pick_key = 't' },
          { icon = '', titles = { 'dap-repl', 'dapui_console' }, pick_key = 'd' },
        },
      },
      statusline = {
        clickable = true,
        colored = true,
        colors = {
          active = 'EdgyGroupActive',
          inactive = 'EdgyGroupInactive',
          pick_active = 'EdgyGroupPickActive',
          pick_inactive = 'EdgyGroupPickInactive',
          separator_active = 'EdgyGroupSeparatorActive',
          separator_inactive = 'EdgyGroupSeparatorInactive',
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
    config = function(_, opts)
      require('edgy-group').setup(opts)
      -- Add autocmd to refresh the statusline when the window is opened
      vim.api.nvim_create_autocmd(
        { 'WinResized' },
        { pattern = { '*' }, callback = function() incline_safe_refresh() end }
      )
    end,
  },
}
