return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>p', group = 'perf' },
        { '<leader>pl', group = 'load' },
        { '<leader>pc', group = 'cyle/cache' },
        { '<leader>ps', group = 'select' },
      },
    },
  },
  {
    't-troebst/perfanno.nvim',
    cmd = {
      'PerfAnnotate',
      'PerfAnnotateFunction',
      'PerfAnnotateSelection',
      'PerfCacheDelete',
      'PerfCacheLoad',
      'PerfCacheSave',
      'PerfCycleFormat',
      'PerfHottestLines',
      'PerfHottestSymbols',
      'PerfLoadCallGraph',
      'PerfLoadFlameGraph',
      'PerfLoadFlat',
      'PerfLuaProfileStart',
      'PerfLuaProfileStop',
      'PerfPickEvent',
      'PerfToggleAnnotations',
    },
    keys = {
      -- Load performance data
      { '<leader>plf', '<cmd>PerfLoadFlat<cr>', desc = 'Perf Load Flat' },
      { '<leader>plg', '<cmd>PerfLoadCallGraph<cr>', desc = 'Perf Load Call Graph' },
      { '<leader>plo', '<cmd>PerfLoadFlameGraph<cr>', desc = 'Perf Load Flame Graph' },

      -- Pick event
      { '<leader>pe', '<cmd>PerfPickEvent<cr>', desc = 'Perf Pick Event' },

      -- Annotate
      { '<leader>pa', '<cmd>PerfAnnotate<cr>', mode = 'n', desc = 'Perf Annotate' },
      { '<leader>pa', '<cmd>PerfAnnotateSelection<cr>', mode = 'v', desc = 'Perf Annotate Selection' },
      { '<leader>pf', '<cmd>PerfAnnotateFunction<cr>', desc = 'Perf Annotate Function' },

      -- Toggle annotations
      { '<leader>pt', '<cmd>PerfToggleAnnotations<cr>', desc = 'Perf Toggle Annotations' },

      -- Select hottest elements
      { '<leader>psh', '<cmd>PerfHottestLines<cr>', desc = 'Perf Hottest Lines' },
      { '<leader>pss', '<cmd>PerfHottestSymbols<cr>', desc = 'Perf Hottest Symbols' },
      { '<leader>psc', '<cmd>PerfHottestCallersFunction<cr>', mode = 'n', desc = 'Perf Hottest Callers Function' },
      { '<leader>psc', '<cmd>PerfHottestCallersSelection<cr>', mode = 'v', desc = 'Perf Hottest Callers Selection' },

      -- Cycle format
      { '<leader>pcf', '<cmd>PerfCycleFormat<cr>', desc = 'Perf Cycle Format' },

      -- Cache operations
      { '<leader>pcs', '<cmd>PerfCacheSave<cr>', desc = 'Perf Cache Save' },
      { '<leader>pcl', '<cmd>PerfCacheLoad<cr>', desc = 'Perf Cache Load' },
      { '<leader>pcd', '<cmd>PerfCacheDelete<cr>', desc = 'Perf Cache Delete' },
    },
    opts = {},
  },
}
