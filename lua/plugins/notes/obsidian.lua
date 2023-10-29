return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      defaults = {
        ['<leader>o'] = { name = '+obsidian' },
      },
    },
  },
  {
    'epwalsh/obsidian.nvim',
    event = 'VeryLazy',
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

      note_id_func = function(title)
        return title
      end,

      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        -- ["gf"] = require("obsidian.mapping").gf_passthrough(),
      },
      -- Optional, set to true if you use the Obsidian Advanced URI plugin.
      -- https://github.com/Vinzent03/obsidian-advanced-uri
      use_advanced_uri = true,

      -- Optional, set to true to force '<cmd>ObsidianOpen' to bring the app to the foreground.
      open_app_foreground = true,
      finder = 'telescope.nvim',
    },
    keys = {
      { '<leader>oo', '<cmd>ObsidianOpen<cr>', desc = 'Obsidian Open' },
      { '<leader>of', '<cmd>ObsidianQuickSwitch<cr>', desc = 'Obsidian Find Files' },
      { '<leader>os', '<cmd>ObsidianSearch<cr>', desc = 'Obsidian Find Files' },
      { '<leader>ot', '<cmd>ObsidianToday<cr>', desc = 'Obsidian Today' },
      { '<leader>oy', '<cmd>ObsidianYesterday<cr>', desc = 'Obsidian Yesterday' },
      { '<leader>on', '<cmd>ObsidianTask<CR>', desc = 'Obsidian Task' },
    },
    config = function(_, opts)
      require('obsidian').setup(opts)

      --- Create a new note with the name of the current task
      local function toggle_current_task()
        -- Get name of the current branch
        local branch = vim.fn.system('git rev-parse --abbrev-ref HEAD')

        -- Get the task based on regex
        local task = branch:match('(%w+%-%d+)')
        if task and task ~= '' then
          vim.cmd('ObsidianNew ' .. task)
        else
          vim.notify('Unable to create note ' .. task, vim.log.levels.WARN)
        end
      end
      vim.api.nvim_create_user_command('ObsidianTask', toggle_current_task, {})

      -- Optional, override the 'gf' keymap to utilize Obsidian's search functionality.
      -- see also: 'follow_url_func' config option above.
      -- TODO: Set this keymap only with ob
      -- vim.keymap.set('n', 'gf', function()
      --   if require('obsidian').util.cursor_on_markdown_link() then
      --     return '<cmd>ObsidianFollowLink<CR>'
      --   else
      --     return 'gf'
      --   end
      -- end, { noremap = false, expr = true })
    end,
  },
}
