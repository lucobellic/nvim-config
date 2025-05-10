-- return the max fold level of the buffer (for now doing the opposite and folding incrementally is unbounded)
-- Also jarring if you start folding incrementally after opening all folds
local function max_level()
  return vim.wo.foldlevel -- find a way for this to return max fold level
  -- return 0
end

local function sendFoldEvent()
  vim.api.nvim_exec_autocmds('User', {
    pattern = 'FoldChanged',
  })
end

---Set the fold level to the provided value and store it locally to the buffer
---@param num integer the fold level to set
local function set_fold(num)
  -- vim.w.ufo_foldlevel = math.min(math.max(0, num), max_level()) -- when max_level is implemneted properly
  vim.b.ufo_foldlevel = math.max(0, num)
  require('ufo').closeFoldsWith(vim.b.ufo_foldlevel)
end

--Shift the current fold level by the provided amount
---@param dir number positive or negative number to add to the current fold level to shift it
local shift_fold = function(dir) set_fold((vim.b.ufo_foldlevel or max_level()) + dir) end

-- when max_level is implemented properly
-- vim.keymap.set("n", "zR", function() set_win_fold(max_level()) end, { desc = "Open all folds" })

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

return {
  'kevinhwang91/nvim-ufo',
  vscode = false,
  dependencies = { 'kevinhwang91/promise-async' },
  keys = {
    {
      'zR',
      function()
        require('ufo').openAllFolds()
        sendFoldEvent()
      end,
      { desc = 'Open all folds' },
    },
    {
      'zM',
      function()
        set_fold(0)
        sendFoldEvent()
      end,
      { desc = 'Close all folds' },
    },

    {
      'zr',
      function()
        shift_fold(vim.v.count == 0 and 1 or vim.v.count)
        sendFoldEvent()
      end,
      repeatable = true,
      desc = 'Fold less',
    },
    {
      'zm',
      function()
        shift_fold(-(vim.v.count == 0 and 1 or vim.v.count))

        sendFoldEvent()
      end,
      repeatable = true,
      desc = 'Fold more',
    },
  },
  opts = {
    fold_virt_text_handler = function(virtual_text, lnum, end_lnum, width, truncate, ctx)
      local default_virtual_text =
        require('ufo.decorator').defaultVirtTextHandler(virtual_text, lnum, end_lnum, width, truncate, ctx)
      table.insert(default_virtual_text, #default_virtual_text, { '  ', 'Normal' })
      return default_virtual_text
    end,
  },
}
