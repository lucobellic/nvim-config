return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/neotest-plenary',
    'nvim-neotest/neotest-vim-test',
    'nvim-neotest/neotest-python',
  },
  cmd = { 'Neotest' },
  opts = function(_, opts)
    -- Configure neotest-python
    opts.adapters = opts.adapters or {}
    opts.adapters['neotest-python'] = vim.tbl_deep_extend('force', opts.adapters['neotest-python'] or {}, {
      runner = 'pytest',
      python = '/usr/bin/python',
      pytest_discover_instances = true, -- experimental
    })

    opts = vim.tbl_deep_extend('force', opts, {
      status = {
        enabled = true,
        virtual_text = true,
        signs = false,
      },
      output = {
        enabled = true,
        open_on_run = false,
      },
      icons = {
        running_animated = { '', '', '', '' },
        passed = '',
        running = '',
        failed = '',
        skipped = '',
        unknown = '',
        non_collapsible = '─',
        collapsed = '─',
        expanded = '╮',
        child_prefix = '├',
        final_child_prefix = '╰',
        child_indent = '│',
        final_child_indent = ' ',
        watching = '',
      },
    })
    return opts
  end,
}
