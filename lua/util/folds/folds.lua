---@class FoldVirtualText.Command
---@field cmd string
---@field desc string
---@field per_cursor? boolean Apply the command at every native multicursor.

---@class FoldVirtualText Module for adding virtual text to folded lines in Neovim
---@field ns integer Namespace for virtual text extmarks
local M = {
  ns = vim.api.nvim_create_namespace('fold_virtual_text'),
}

local multicursor_namespace = vim.api.nvim_create_namespace('nvim.multicursor')

--- Methods where Neovim lets the user create and delete folds by hand
local editable_foldmethods = { manual = true, marker = true }

--- Build the keys to replay, keeping the count typed before the mapping
---@param command string
---@return string
local function with_count(command) return (vim.v.count > 0 and vim.v.count or '') .. command end

---@param keys string
local function run_normal(keys) pcall(vim.cmd.normal, { keys, bang = true }) end

---@param keys string
local function run_at_every_cursor(keys)
  local multicursors = vim.api.nvim_buf_get_extmarks(0, multicursor_namespace, 0, -1, {})
  local primary_view = vim.fn.winsaveview()

  run_normal(keys)
  vim.iter(multicursors):each(function(multicursor)
    vim.api.nvim_win_set_cursor(0, { multicursor[2] + 1, multicursor[3] })
    run_normal(keys)
  end)

  if #multicursors > 0 then
    vim.fn.winrestview(primary_view)
  end
end

---@param fold_command FoldVirtualText.Command
local function run_fold_command(fold_command)
  local keys = with_count(fold_command.cmd)
  if fold_command.per_cursor then
    run_at_every_cursor(keys)
  else
    run_normal(keys)
  end
  vim.api.nvim_exec_autocmds('User', { pattern = 'FoldChanged' })
end

---@param fold_command FoldVirtualText.Command
local function run_manual_fold_command(fold_command)
  -- Switching to manual keeps the current folds, so the user can edit them by hand
  if not editable_foldmethods[vim.wo.foldmethod] then
    vim.wo[0][0].foldmethod = 'manual'
  end
  run_normal(fold_command.cmd)
  vim.api.nvim_exec_autocmds('User', { pattern = 'FoldChanged' })
end

---@param bufnr integer
---@param row integer 0 based first line of the closed fold
---@param fold_end integer 1 based last line of the closed fold
local function add_fold_label(bufnr, row, fold_end)
  local line_content = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''

  vim.api.nvim_buf_set_extmark(bufnr, M.ns, row, #line_content, {
    virt_text = {
      { ' ', 'Normal' },
      { ' +' .. (fold_end - row) .. '  ', 'UfoFoldedEllipsis' },
    },
    virt_text_pos = 'overlay',
    ephemeral = true,
  })
end

--- Label each closed fold while it is drawn, so folds from any source show their size
---@param winid integer
---@param bufnr integer
---@param row integer
local function decorate_range(_, winid, bufnr, row)
  local fold_end = vim.api.nvim_win_call(
    winid,
    function() return vim.fn.foldclosed(row + 1) == row + 1 and vim.fn.foldclosedend(row + 1) or -1 end
  )

  if fold_end ~= -1 then
    add_fold_label(bufnr, row, fold_end)
  end
end

---@param fold_command FoldVirtualText.Command
local function map_normal_fold_command(fold_command)
  vim.keymap.set(
    'n',
    fold_command.cmd,
    function() run_fold_command(fold_command) end,
    { desc = fold_command.desc, repeatable = true }
  )
end

---@param fold_command FoldVirtualText.Command
local function map_visual_fold_command(fold_command)
  vim.keymap.set(
    'x',
    fold_command.cmd,
    function() run_manual_fold_command(fold_command) end,
    { desc = fold_command.desc }
  )
end

--- Set up the fold labels and fold keymaps
function M.setup()
  -- An empty foldtext draws the real first line, which the label sits after
  vim.o.foldtext = ''

  vim.api.nvim_set_decoration_provider(M.ns, {
    on_range = decorate_range,
  })

  ---@type FoldVirtualText.Command[]
  local normal_fold_commands = {
    { cmd = 'zo', desc = 'Open fold under cursor', per_cursor = true },
    { cmd = 'zO', desc = 'Open all folds under cursor recursively', per_cursor = true },
    { cmd = 'zc', desc = 'Close fold under cursor', per_cursor = true },
    { cmd = 'zC', desc = 'Close all folds under cursor recursively', per_cursor = true },
    { cmd = 'za', desc = 'Toggle fold under cursor', per_cursor = true },
    { cmd = 'zA', desc = 'Toggle all folds under cursor recursively', per_cursor = true },
    { cmd = 'zv', desc = 'View cursor line (open folds to reveal cursor)', per_cursor = true },
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

  ---@type FoldVirtualText.Command[]
  local visual_fold_commands = {
    { cmd = 'zf', desc = 'Create fold from selection' },
    { cmd = 'zF', desc = 'Create fold from selection (alternative)' },
    { cmd = 'zd', desc = 'Delete fold under cursor' },
    { cmd = 'zD', desc = 'Delete all folds under cursor recursively' },
    { cmd = 'zE', desc = 'Eliminate all folds in window' },
  }

  vim.iter(normal_fold_commands):each(map_normal_fold_command)

  --- Allow visual mode folding commands to work with any foldmethod
  vim.iter(visual_fold_commands):each(map_visual_fold_command)

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

  -- LazyVim already picks treesitter or LSP folds per window
  if vim.g.distribution ~= 'lazyvim' then
    vim.o.foldmethod = 'expr'
    -- The builtin expression returns no folds when a buffer has no parser
    vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end
end

return M
