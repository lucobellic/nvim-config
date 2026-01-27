return {
  'anuvyklack/windows.nvim',
  enabled = false,
  event = 'VeryLazy',
  dependencies = {
    'anuvyklack/middleclass',
  },
  init = function()
    vim.o.winwidth = 10
    vim.o.winminwidth = 10
    vim.o.equalalways = false
  end,
  opts = {
    ignore = {
      buftype = { 'quickfix', 'nofile', 'neo-tree' },
      filetype = {
        'DiffviewFiles',
        'NvimTree',
        'neo-tree',
        'undotree',
        'undo',
        'Outline',
        'dapui_scopes',
        'dapui_breakpoints',
        'dapui_stacks',
        'dapui_watches',
        'toggleterm',
      },
    },
    animation = {
      enable = false,
      duration = 500,
      fps = 60,
      easing = 'in_out_sine',
    },
  },
}
