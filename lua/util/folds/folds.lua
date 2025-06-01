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
    { cmd = 'zo', desc = 'Open fold under cursor' },
    { cmd = 'zO', desc = 'Open all folds under cursor recursively' },
    { cmd = 'zc', desc = 'Close fold under cursor' },
    { cmd = 'zC', desc = 'Close all folds under cursor recursively' },
    { cmd = 'za', desc = 'Toggle fold under cursor' },
    { cmd = 'zA', desc = 'Toggle all folds under cursor recursively' },
    { cmd = 'zv', desc = 'View cursor line (open folds to reveal cursor)' },
    { cmd = 'zx', desc = 'Update folds (undo manually opened/closed folds)' },
    { cmd = 'zX', desc = 'Undo manually opened/closed folds' },
    { cmd = 'zm', desc = 'Fold more (increase foldlevel)' },
    { cmd = 'zM', desc = 'Close all folds' },
    { cmd = 'zr', desc = 'Reduce folds (decrease foldlevel)' },
    { cmd = 'zR', desc = 'Open all folds' },
    { cmd = 'zn', desc = 'Fold none (disable folding)' },
    { cmd = 'zN', desc = 'Fold normal (enable folding)' },
    { cmd = 'zi', desc = 'Invert folding' },
  }

  local visual_fold_commands = {
    { cmd = 'zf', desc = 'Create fold from selection' },
    { cmd = 'zF', desc = 'Create fold from selection (alternative)' },
    { cmd = 'zd', desc = 'Delete fold under cursor' },
    { cmd = 'zD', desc = 'Delete all folds under cursor recursively' },
    { cmd = 'zE', desc = 'Eliminate all folds in window' },
  }

  for _, fold_cmd in ipairs(normal_fold_commands) do
    vim.keymap.set('n', fold_cmd.cmd, function()
      vim.cmd('normal! ' .. fold_cmd.cmd)
      vim.schedule(M.add_fold_virtual_text)
    end, { desc = fold_cmd.desc, repeatable = true })
  end

  --- Allow visual mode folding commands to work with any foldmethod
  for _, fold_cmd in ipairs(visual_fold_commands) do
    vim.keymap.set('v', fold_cmd.cmd, function()
      local previous_foldmethod = vim.wo.foldmethod
      vim.wo.foldmethod = 'manual'
      vim.cmd('normal! ' .. fold_cmd.cmd)
      vim.schedule(M.add_fold_virtual_text)
      vim.wo.foldmethod = previous_foldmethod
    end, { desc = fold_cmd.desc })
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

  if vim.g.distribution ~= 'lazyvim' then
    vim.opt.foldexpr = "v:lua.require('util.folds.folds').foldexpr()"
  end
end

function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filetype, don't bother
    -- checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == '' then
      return '0'
    end
    if vim.bo[buf].filetype:find('dashboard') then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or '0'
end

return M
