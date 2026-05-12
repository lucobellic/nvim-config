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

---@param opts obsidian.config
local function configure_blink_source(opts)
  local blink_ok, blink_config = pcall(require, 'blink.cmp.config')
  if blink_ok then
    local obsidian_providers = { obsidian = 10, obsidian_tags = 10 }
    if opts.completion and opts.completion.create_new ~= false then
      obsidian_providers.obsidian_new = 10
    end
    for id, offset in pairs(obsidian_providers) do
      if blink_config.sources.providers[id] then
        blink_config.sources.providers[id].score_offset = offset
      end
    end
  end
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
    version = '3.16.3',
    cond = vim.fn.isdirectory(vim.fn.expand('~/vaults')) == 1,
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
      { '<leader>ny', '<cmd>Obsidian yesterday<cr>', desc = 'Obsidian Yesterday' },
      { '<leader>nn', '<cmd>ObsidianTask<CR>', desc = 'Obsidian Task' },
      { '<leader>nw', '<cmd>Obsidian workspace<CR>', desc = 'Obsidian Workspace' },
    },
    ft = { 'markdown' },
    --- @type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = get_workspaces(),
      notes_subdir = 'notes',
      templates = { enabled = false },
      frontmatter = { enabled = false },
      daily_notes = {
        folder = 'dailies',
      },
      completion = {
        nvim_cmp = false, -- if using nvim-cmp, otherwise set to false
        blink = true,
        min_chars = 0,
      },
      note_id_func = function(title) return title end,
      ui = {
        enable = false, -- Prefer usage of mardown.nvim
      },
      picker = { name = 'snacks.pick' },
    },
    config = function(_, opts)
      require('obsidian').setup(opts)

      configure_blink_source(opts)
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
