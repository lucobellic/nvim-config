--- @class FoldVirtualText Module for adding virtual text to folded lines in Neovim
--- @field ns integer Namespace for virtual text extmarks
local M = {
  ns = vim.api.nvim_create_namespace('fold_virtual_text'),
}

--- Add virtual text for folded lines in the current buffer
--- Clears existing virtual text and adds new overlays for all closed folds
function M.add_fold_virtual_text()
  -- Clear existing virtual text
  vim.api.nvim_buf_clear_namespace(0, M.ns, 0, -1)

  -- Get all folds in the current buffer
  local line_count = vim.api.nvim_buf_line_count(0)

  for line = 1, line_count do
    local fold_closed = vim.fn.foldclosed(line)

    if fold_closed ~= -1 and fold_closed == line then
      -- This is the first line of a closed fold
      local fold_end = vim.fn.foldclosedend(line)
      local lines_folded = fold_end - line + 1

      -- Get the line content to determine overlay position
      local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ''
      local col = #line_content

      vim.api.nvim_buf_set_extmark(0, M.ns, line - 1, col, {
        virt_text = {
          { ' ', 'Normal' },
          { ' +' .. lines_folded .. '  ', 'UfoFoldedEllipsis' },
        },
        virt_text_pos = 'overlay',
        virt_text_hide = false,
        invalidate = true,
      })
    end
  end
end

--- Set up autocommands and keymaps for fold virtual text
--- Creates autocommands for buffer events and cursor movements
--- Overrides fold-related keymaps to trigger virtual text updates
function M.setup()
  -- Set up autocommands to update virtual text when folds change
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'WinEnter' }, {
    callback = M.add_fold_virtual_text,
  })

  local normal_fold_commands = {
    'zo',
    'zO',
    'zc',
    'zC',
    'za',
    'zA',
    'zv',
    'zx',
    'zX',
    'zm',
    'zM',
    'zr',
    'zR',
    'zn',
    'zN',
    'zi',
  }

  local visual_fold_commands = {
    'zf',
    'zF',
    'zd',
    'zD',
    'zE',
  }

  for _, cmd in ipairs(normal_fold_commands) do
    vim.keymap.set('n', cmd, function()
      vim.cmd('normal! ' .. cmd)
      vim.schedule(M.add_fold_virtual_text)
    end)
  end

  --- Allow visual mode folding commands to work with any foldmethod
  for _, cmd in ipairs(visual_fold_commands) do
    vim.keymap.set('v', cmd, function()
      local previous_foldmethod = vim.wo.foldmethod
      vim.wo.foldmethod = 'manual'
      vim.cmd('normal! ' .. cmd)
      vim.schedule(M.add_fold_virtual_text)
      vim.wo.foldmethod = previous_foldmethod
    end)
  end

  if vim.g.vscode then
    local vscode = require('vscode')

    vim.keymap.set('n', 'zM', function() vscode.action('editor.foldAll') end)
    vim.keymap.set('n', 'zR', function() vscode.action('editor.unfoldAll') end)
    vim.keymap.set('n', 'zc', function() vscode.action('editor.fold') end)
    vim.keymap.set('n', 'zC', function() vscode.action('editor.foldRecursively') end)
    vim.keymap.set('n', 'zo', function() vscode.action('editor.unfold') end)
    vim.keymap.set('n', 'zO', function() vscode.action('editor.unfoldRecursively') end)
    vim.keymap.set('n', 'za', function() vscode.action('editor.toggleFold') end)
  end
end

return M
