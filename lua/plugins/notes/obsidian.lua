return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>oo'] = { name = 'obsidian' },
      },
    },
  },
  {
    'epwalsh/obsidian.nvim',
    enabled = vim.fn.filereadable(vim.fn.expand('~/vault/work')),
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      dir = '~/vault/work', -- no need to call 'vim.fn.expand' here
      notes_subdir = 'notes',
      daily_notes = {
        folder = 'dailies',
      },
      completion = {
        nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
      },
      disable_frontmatter = true,

      note_id_func = function(title) return title end,

      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        ['gf'] = {
          action = function() return require('obsidian').util.gf_passthrough() end,
          opts = { noremap = false, expr = true, buffer = true },
        },
      },
      -- Optional, set to true if you use the Obsidian Advanced URI plugin.
      -- https://github.com/Vinzent03/obsidian-advanced-uri
      use_advanced_uri = true,

      -- Optional, set to true to force '<cmd>ObsidianOpen' to bring the app to the foreground.
      open_app_foreground = true,
      finder = 'telescope.nvim',

      ui = {
        enabled = true,
        checkboxes = {
          [' '] = { char = '󱍫', hl_group = 'DiagnosticInfo' },
          ['x'] = { char = '󱍧', hl_group = 'DiagnosticOk' },
          ['/'] = { char = '󱍬', hl_group = 'DiagnosticWarn' },
          ['%-'] = { char = '󱍮', hl_group = 'DiagnosticError' },
          ['%?'] = { char = '󱍥', hl_group = 'DiagnosticWarn' },
        },
      },
    },
    cmd = {
      'ObsidianOpen',
      'ObsidianQuickSwitch',
      'ObsidianSearch',
      'ObsidianToday',
      'ObsidianYesterday',
      'ObsidianTask',
    },
    keys = {
      { '<leader>ooo', '<cmd>ObsidianOpen<cr>', desc = 'Obsidian Open' },
      { '<leader>oof', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Obsidian Find Files' },
      { '<leader>oos', '<cmd>ObsidianSearch<cr>', desc = 'Obsidian Find Files' },
      { '<leader>oot', '<cmd>ObsidianToday<cr>', desc = 'Obsidian Today' },
      { '<leader>ooy', '<cmd>ObsidianYesterday<cr>', desc = 'Obsidian Yesterday' },
      { '<leader>oon', '<cmd>ObsidianTask<CR>', desc = 'Obsidian Task' },
    },
    ft = 'markdown',
    config = function(_, opts)
      require('obsidian').setup(opts)

      --- Create a new note with the name of the current task
      local function toggle_current_task()
        -- Get name of the current branch
        local branch = vim.fn.system('git rev-parse --abbrev-ref HEAD')

        -- Get the task based on regex
        local task = branch and branch:match('(%w+%-%d+)') or ''
        if task ~= '' then
          vim.cmd('ObsidianNew ' .. task)
        else
          vim.notify('Unable to create note', vim.log.levels.WARN, { title = 'obsidian.nvim' })
        end
      end
      vim.api.nvim_create_user_command('ObsidianTask', toggle_current_task, {})
    end,
  },
}
