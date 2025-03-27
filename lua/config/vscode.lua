if not vim.g.vscode then
  return {}
end

local vscode = require('vscode')
vim.notify = vscode.notify

-- Define all mappings in a table
local mappings = {
  n = {
    ['j'] = { "v:count == 0 ? 'gj' : 'j'", noremap = false, silent = true },
    ['k'] = { "v:count == 0 ? 'gk' : 'k'", noremap = false, silent = true },
    -- Format
    ['<leader>='] = {
      function() vscode.action('editor.action.formatDocument') end,
      desc = 'Format document',
    },
    -- File Explorer
    ['<leader>fe'] = {
      function() vscode.action('workbench.explorer.fileView.focus') end,
      desc = 'Focus file explorer',
    },
    -- Toggle Shortcut
    ['<leader>;e'] = {
      function() vscode.action('workbench.action.toggleSidebarVisibility') end,
      desc = 'Toggle sidebar visibility',
    },
    ['<leader>;p'] = {
      function() vscode.action('workbench.action.terminal.toggleTerminal') end,
      desc = 'Toggle terminal',
    },
    ['<leader>ub'] = {
      function() vscode.action('gitlens.toggleReviewMode') end,
      desc = 'Line Blame',
    },
    -- Toggle Bars
    ['<leader>w'] = { '<C-w>', remap = true },
    ['<leader>wl'] = {
      function() vscode.action('workbench.action.toggleAuxiliaryBar') end,
      desc = 'Toggle right bar',
    },
    ['<leader>wh'] = {
      function() vscode.action('workbench.action.toggleSidebarVisibility') end,
      desc = 'Toggle left bar',
    },
    ['<leader>wj'] = {
      function() vscode.action('workbench.action.togglePanel') end,
      desc = 'Toggle panel',
    },
    -- Windows
    ['<C-q>'] = {
      function() vscode.action('workbench.action.closeActiveEditor') end,
      desc = 'Close active editor',
    },
    ['<c-up>'] = {
      function() vscode.action('workbench.action.increaseViewHeight') end,
      desc = 'Increase Window Height',
    },
    ['<c-down>'] = {
      function() vscode.action('workbench.action.decreaseViewHeight') end,
      desc = 'Decrease Window Height',
    },
    ['<c-left>'] = {
      function() vscode.action('workbench.action.decreaseViewWidth') end,
      desc = 'Decrease Window Width',
    },
    ['<c-right>'] = {
      function() vscode.action('workbench.action.increaseViewWidth') end,
      desc = 'Increase Window Width',
    },
  },
}

return {
  'AstroNvim/astrocore',
  ---@type AstroCoreOpts
  opts = {
    mappings = mappings,
  },
}
