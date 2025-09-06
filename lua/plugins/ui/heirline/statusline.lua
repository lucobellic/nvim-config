local colors = require('plugins.ui.heirline.colors').colors

local primary_mode_colors = {
  n = { fg = colors.dark_gray },
  i = { bg = colors.green, fg = colors.black },
  v = { bg = colors.orange, fg = colors.black },
  V = { bg = colors.orange, fg = colors.black },
  ['\22'] = { bg = colors.orange, fg = colors.black },
  c = { bg = colors.blue, fg = colors.black },
  s = { bg = colors.purple, fg = colors.black },
  S = { bg = colors.purple, fg = colors.black },
  ['\19'] = { bg = colors.purple, fg = colors.black },
  R = { bg = colors.red, fg = colors.black },
  r = { bg = colors.red, fg = colors.black },
  ['!'] = { bg = colors.blue, fg = colors.black },
  t = { bg = colors.purple, fg = colors.black },
}

local secondary_mode_colors = {
  n = { fg = colors.dark_gray },
  i = { fg = colors.green },
  v = { fg = colors.orange },
  V = { fg = colors.orange },
  ['\22'] = { fg = colors.orange },
  c = { fg = colors.blue },
  s = { fg = colors.purple },
  S = { fg = colors.purple },
  ['\19'] = { fg = colors.purple },
  R = { fg = colors.red },
  r = { fg = colors.red },
  ['!'] = { fg = colors.blue },
  t = { fg = colors.purple },
}

local function get_mode()
  local mode = vim.fn.mode(1) or 'n'
  return mode:sub(1, 1)
end

local primary_highlight = function() return primary_mode_colors[get_mode()] end
local secondary_highlight = function() return secondary_mode_colors[get_mode()] end

local function highlight_change_setup()
  -- List of highlight groups to manage
  local hl_names = {
    'EdgyGroupActiveBottom',
    'EdgyGroupInactiveBottom',
    'EdgyGroupPickActiveBottom',
    'EdgyGroupPickInactiveBottom',
    'EdgyGroupSeparatorActiveBottom',
    'EdgyGroupSeparatorInactiveBottom',
  }

  -- Store the default highlights at startup
  local function update_highlights()
    local mode = get_mode()
    if mode == 'n' then
      -- Restore default highlights link
      for _, name in ipairs(hl_names) do
        vim.api.nvim_set_hl(0, name, { link = name:gsub('Bottom', '') })
      end
    else
      local hl = primary_highlight()
      if hl and hl.bg then
        for _, name in ipairs(hl_names) do
          vim.api.nvim_set_hl(0, name, { bg = hl.bg, fg = colors.black })
        end
      end
    end
  end

  vim.api.nvim_create_autocmd({ 'ModeChanged' }, {
    callback = function() update_highlights() end,
  })
end

local left_components_length = 0

local PrimarySpace = {
  provider = ' ',
  hl = primary_highlight,
}

local SecondarySpace = {
  provider = ' ',
  hl = secondary_highlight,
}

-------------------------------------- Left -------------------------------------

-- Trigger ModeChanged as a User autocmd to allow heirline update to use it
vim.api.nvim_create_autocmd('ModeChanged', {
  callback = vim.schedule_wrap(function() vim.api.nvim_exec_autocmds('User', { pattern = 'ModeChanged' }) end),
})

local ViMode = {
  init = function() left_components_length = 4 end,
  provider = function() return '   ' end,
  hl = primary_highlight,
}

local CPU = {
  init = function() return require('plugins.ui.heirline.utils.system').start_auto_update() end,
  provider = function() return require('plugins.ui.heirline.utils.system').system_stats_cache.cpu end,
  update = {
    'User',
    pattern = { 'CpuUpdated', 'ModeChanged' },
  },
  hl = primary_highlight,
}

local GPU = {
  init = function() return require('plugins.ui.heirline.utils.system').start_auto_update() end,
  provider = function() return require('plugins.ui.heirline.utils.system').system_stats_cache.gpu end,
  update = {
    'User',
    pattern = { 'GpuUpdated', 'ModeChanged' },
  },
  hl = primary_highlight,
}

local Memory = {
  init = function() return require('plugins.ui.heirline.utils.system').start_auto_update() end,
  provider = function() return require('plugins.ui.heirline.utils.system').system_stats_cache.memory end,
  update = {
    'User',
    pattern = { 'MemoryUpdated', 'ModeChanged' },
  },
  hl = primary_highlight,
}

local Git = {
  condition = function() return require('heirline.conditions').is_git_repo() end,
  init = function(self)
    ---@diagnostic disable-next-line: undefined-field
    self.status_dict = vim.b.gitsigns_status_dict
    self.text = ' ' .. self.status_dict.head .. ' '
    -- Truncate text if it's too long more than 20 characters
    if #self.text > 20 then
      self.text = string.sub(self.text, 1, 20) .. '...'
    end
    left_components_length = left_components_length + vim.api.nvim_eval_statusline(self.text, {}).width
  end,
  provider = function(self) return self.text end,
  hl = primary_highlight,
}

local Molten = {
  condition = function() return package.loaded.molten end,
  init = function(self)
    kernels = require('molten.status').kernels()
    self.text = kernels ~= '' and '  (' .. kernels .. ') ' or ''
    left_components_length = left_components_length + vim.api.nvim_eval_statusline(self.text, {}).width
  end,
  provider = function(self) return self.text end,
  hl = secondary_highlight,
}

local Dap = {
  condition = function()
    local ok, dap = pcall(require, 'dap')
    return ok and dap.session() ~= nil
  end,
  init = function(self)
    self.text = '  ' .. require('dap').status()
    left_components_length = left_components_length + vim.api.nvim_eval_statusline(self.text, {}).width
  end,
  provider = function(self) return self.text end,
  hl = primary_highlight,
}

local MacroRec = {
  condition = function() return vim.fn.reg_recording() ~= '' and vim.o.cmdheight == 0 end,
  init = function(self)
    self.text = ' ' .. vim.fn.reg_recording()
    left_components_length = left_components_length + vim.api.nvim_eval_statusline(self.text, {}).width
  end,
  provider = function(self) return self.text end,
  hl = { fg = colors.orange, italic = true },
}

------------------------------------ Center -------------------------------------

local LeftAlignment = {
  init = function(self)
    local mid_screen = math.floor(vim.api.nvim_get_option_value('columns', {}) / 2)
    local mid_section = table.concat(require('edgy-group.stl').get_statusline('bottom'))
    local mid_width = math.floor(vim.api.nvim_eval_statusline(mid_section, {}).width / 2)
    local nb_spaces = mid_screen - left_components_length - mid_width
    local left_padding = string.rep(' ', nb_spaces > 0 and nb_spaces - 1 or 0)
    self.text = left_padding
  end,
  provider = function(self) return self.text end,
  hl = { bg = 'none' },
}

local Edgy = {
  init = function(self) self.text = table.concat(require('edgy-group.stl').get_statusline('bottom')) end,
  provider = function(self) return self.text end,
  hl = { bg = 'none' },
}

------------------------------------ Right -------------------------------------

local Spacer = { provider = ' ' }
local function rpad(child)
  return {
    condition = child.condition,
    child,
    Spacer,
  }
end

local function OverseerTasksForStatus(status)
  return {
    condition = function(self) return self.tasks[status] end,
    provider = function(self) return string.format('%s%d', self.symbols[status], #self.tasks[status]) end,
    hl = function()
      return {
        fg = require('heirline.utils').get_highlight(string.format('Overseer%s', status)).fg,
      }
    end,
  }
end

local Overseer = {
  condition = function() return package.loaded.overseer end,
  init = function(self)
    local tasks = require('overseer.task_list').list_tasks({ unique = true })
    local tasks_by_status = require('overseer.util').tbl_group_by(tasks, 'status')
    self.tasks = tasks_by_status
  end,
  static = {
    symbols = {
      ['FAILURE'] = ' ',
      ['CANCELED'] = ' ',
      ['SUCCESS'] = ' ',
      ['RUNNING'] = ' ',
    },
  },

  rpad(OverseerTasksForStatus('CANCELED')),
  rpad(OverseerTasksForStatus('RUNNING')),
  rpad(OverseerTasksForStatus('SUCCESS')),
  rpad(OverseerTasksForStatus('FAILURE')),
}

local copilot_icons = {
  Normal = '',
  Disabled = '',
  Warning = '',
  Unknown = '',
}

local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local spinner_index = 1
local function get_spinner()
  spinner_index = spinner_index % #spinner + 1
  return spinner[spinner_index]
end

local function get_copilot_icons()
  local copilot_client_ok, copilot_client = pcall(require, 'copilot.client')
  local copilot_status_ok, copilot_status = pcall(require, 'copilot.status')
  if copilot_client_ok and copilot_client.is_disabled() then
    return ' ' .. copilot_icons.Disabled
  elseif copilot_status_ok and copilot_status.data.status == 'InProgress' then
    return get_spinner() .. ' ' .. copilot_icons.Normal
  end
  local icon = copilot_status_ok and copilot_icons[copilot_status.data.status]
  return icon and (' ' .. icon) or (' ' .. copilot_icons.Warning)
end

local Copilot = {
  condition = function()
    local ok, copilot_client = pcall(require, 'copilot.client')
    return ok and not copilot_client.is_disabled() and copilot_client.buf_is_attached(vim.api.nvim_get_current_buf())
  end,
  update = {
    'User',
    pattern = { 'CopilotStatusUpdated', 'ModeChanged' },
    callback = vim.schedule_wrap(function() vim.cmd('redrawstatus') end),
  },
  provider = function() return get_copilot_icons() .. ' ' end,
  hl = secondary_highlight,
}

local codecompanion_processing = false
local codecompanion_timer = vim.uv.new_timer()

-- Schedule event every 200ms when code companion request started until finished
vim.api.nvim_create_autocmd('User', {
  pattern = 'CodeCompanionRequest*',
  callback = function(args)
    if args.match == 'CodeCompanionRequestStarted' then
      codecompanion_processing = true
      codecompanion_timer:start(
        0,
        200,
        vim.schedule_wrap(function() vim.api.nvim_exec_autocmds('User', { pattern = 'CodeCompanionUpdated' }) end)
      )
    elseif args.match == 'CodeCompanionRequestFinished' then
      codecompanion_processing = false
      codecompanion_timer:stop()
      vim.schedule_wrap(function() vim.cmd('redrawstatus') end)
    end
  end,
})

local function get_codecompanion_icons() return codecompanion_processing and get_spinner() .. ' ' or ' ' end

local CodeCompanion = {
  provider = function() return get_codecompanion_icons() .. ' ' end,
  udpate = {
    'User',
    pattern = { 'CodeCompanionUpdated', 'ModeChanged' },
    callback = vim.schedule_wrap(function() vim.cmd('redrawstatus') end),
  },
  hl = secondary_highlight,
}

local LspProgress = {
  provider = function() return require('lsp-progress').progress() .. ' ' end,
  update = {
    'User',
    pattern = { 'LspProgressStatusUpdated', 'ModeChanged' },
    callback = vim.schedule_wrap(function() vim.cmd('redrawstatus') end),
  },
  hl = secondary_highlight,
}

local SearchCount = {
  condition = function() return vim.v.hlsearch ~= 0 and vim.o.cmdheight == 0 end,
  init = function(self)
    local ok, search = pcall(vim.fn.searchcount)
    if ok and search.total then
      self.search = search
    end
  end,
  provider = function(self)
    return self.search
        and string.format('[%d/%d] ', self.search.current, math.min(self.search.total, self.search.maxcount))
      or ''
  end,
  hl = secondary_highlight,
}

local Ruler = {
  -- %l = current line number
  -- %c = column number
  provider = ' %3l:%-3c ',
  hl = secondary_highlight,
}

local Date = {
  provider = function() return '  ' .. os.date('%Hh%M') .. ' ' end,
  hl = primary_highlight,
}

local Separator = {
  provider = function() return get_mode() == 'n' and ' ' or '┃' end,
  hl = secondary_highlight,
}

local Left = { ViMode, Git, Separator, Dap, Molten, MacroRec }
local Center = { LeftAlignment, Separator, Edgy, Separator }
local Align = { provider = '%=', hl = { bg = 'none' } }
local SystemStats = {
  PrimarySpace,
  CPU,
  GPU,
  Memory,
}
local Right = {
  Overseer,
  LspProgress,
  Copilot,
  CodeCompanion,
  -- SystemStats,
  SearchCount,
  Separator,
  Date,
}

highlight_change_setup()
return { Left, Center, Align, Right }
