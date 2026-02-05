local vaults_overrides = {
  notes_subdir = 'notes',
  daily_notes = {
    folder = 'dailies',
    format = '%d-%m-%Y',
  },
}

local function get_workspaces()
  local workspaces = {
    {
      name = 'personal',
      path = '~/vaults/personal',
      overrides = vaults_overrides,
    },
    {
      name = 'work',
      path = '~/vaults/work',
      overrides = vaults_overrides,
    },
  }
  if vim.env.INSIDE_DOCKER then
    workspaces = {
      workspaces[2],
      workspaces[1],
    }
  end
  return workspaces
end

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>n', group = 'notes' },
        { '<leader>nj', group = 'jupytext' },
      },
    },
  },
  {
    'obsidian-nvim/obsidian.nvim',
    version = '3.15.5',
    cond = vim.fn.isdirectory(vim.fn.expand('~/vaults/work')) == 1,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'snacks.nvim',
    },
    cmd = {
      'Obsidian',
    },
    keys = {
      { '<leader>no', '<cmd>Obsidian open<cr>', desc = 'Obsidian Open' },
      { '<leader>nf', '<cmd>Obsidian quick_switch<cr>', desc = 'Obsidian Find Files' },
      { '<leader>nt', '<cmd>Obsidian today<cr>', desc = 'Obsidian Today' },
      { '<leader>ny', '<cmd>Obsidian yesterday<cr>', desc = 'Obsidian Yesterday' },
      { '<leader>nn', '<cmd>ObsidianTask<CR>', desc = 'Obsidian Task' },
      { '<leader>nw', '<cmd>Obsidian workspace<CR>', desc = 'Obsidian Workspace' },
    },
    --- @type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = get_workspaces(),
      notes_subdir = 'notes',
      daily_notes = {
        folder = 'dailies',
      },
      completion = {
        nvim_cmp = false, -- if using nvim-cmp, otherwise set to false
      },
      note_id_func = function(title) return title end,
      ui = {
        enable = false, -- Prefer usage of mardown.nvim
      },
      picker = { name = 'snacks.pick' },
    },
    config = function(_, opts)
      require('obsidian').setup(opts)

      --- Create a new note with the name of the current task
      local function toggle_current_task()
        -- Get name of the current branch
        local branch = vim.fn.system('git rev-parse --abbrev-ref HEAD')

        -- Get the task based on regex
        local task = branch and branch:match('(%w+%-%d+)') or ''
        if task ~= '' then
          vim.cmd('Obsidian new ' .. task)
        else
          vim.notify('Unable to create note', vim.log.levels.WARN, { title = 'obsidian.nvim' })
        end
      end
      vim.api.nvim_create_user_command('ObsidianTask', toggle_current_task, {})
    end,
  },
}
