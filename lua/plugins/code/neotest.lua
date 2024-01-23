return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/neotest-plenary',
    'nvim-neotest/neotest-vim-test',
    'nvim-neotest/neotest-python',
  },
  opts = {
    adapters = {
      'neotest-plenary',
      'neotest-vim-test',
      ['neotest-python'] = {
        runner = 'pytest',
        python = '/usr/bin/python',
      },
    },
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
  },
}
