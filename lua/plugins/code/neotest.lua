return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/neotest-plenary',
    'nvim-neotest/neotest-vim-test',
    'nvim-neotest/neotest-python',
    { 'rouge8/neotest-rust', enabled = false }, -- disable neotest-rust in favor of rustaceanvim
    'mrcjkb/rustaceanvim',
  },
  cmd = { 'Neotest' },
  opts = {
    adapters = {},
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
  config = function(_, opts)
    opts.adapters = {
      require('neotest-plenary'),
      require('neotest-vim-test'),
      require('neotest-python')({
        runner = 'pytest',
        python = '/usr/bin/python',
        pytest_discover_instances = true, -- experimental
      }),
      require('rustaceanvim.neotest'),
    }
    opts.consumers = {
      overseer = require('neotest.consumers.overseer'),
    }
    require('neotest').setup(opts)
  end,
}
