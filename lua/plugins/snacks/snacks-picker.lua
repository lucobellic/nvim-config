---@module 'snacks.picker'

local preferred = {
  'vertical',
  'telescope_preview',
  'telescope_vertical',
  'bottom',
  'default',
  'ivy',
  'ivy_split',
  'left',
  'right',
  'select',
  'sidebar',
  'telescope',
  'top',
  'telescope_no_preview',
  'dropdown',
  'vscode',
}

---@type snacks.picker.layout.Config
local telescope_no_preview = {
  preset = 'telescope',
  previewer = false,
  reverse = false,
  cycle = true,
  ---@type snacks.layout.Box
  layout = {
    box = 'horizontal',
    backdrop = false,
    width = 0.5,
    height = 0.5,
    border = 'none',
    {
      box = 'vertical',
      border = vim.g.border.style,
      title = '{title} {live} {flags}',
      title_pos = 'center',
      { win = 'input', height = 1, border = 'bottom' },
      { win = 'list', title = ' Results ', title_pos = 'center', border = 'none' },
    },
  },
}

---@type snacks.picker.layout.Config
local telescope_preview = {
  preset = 'telescope_no_preview',
  layout = {
    box = 'horizontal',
    backdrop = vim.g.neovide == true,
    width = 0.9,
    height = 0.9,
    {
      box = 'vertical',
      border = vim.g.border.style,
      title = '{title} {live} {flags}',
      title_pos = 'center',
      { win = 'input', height = 1, border = 'bottom' },
      { win = 'list', title = ' Results ', title_pos = 'center', border = 'none' },
      {
        win = 'preview',
        title = '{preview:Preview}',
        height = 0.75,
        border = 'top',
        title_pos = 'center',
      },
    },
  },
}

---@type snacks.picker.layout.Config
local telescope_vertical = {
  preset = 'telescope_preview',
  layout = {
    box = 'horizontal',
    backdrop = vim.g.neovide == true,
    width = 0.9,
    height = 0.9,
    {
      box = 'vertical',
      border = vim.g.border.style,
      title = '{title} {live} {flags}',
      title_pos = 'center',
      { win = 'input', height = 1, border = 'bottom' },
      { win = 'list', title = ' Results ', title_pos = 'center', border = 'none' },
    },
    { win = 'preview', width = 0.65, title = '{preview:Preview}', title_pos = 'center', border = vim.g.border.style },
  },
}

---@param picker snacks.Picker
local function set_next_preferred_layout(picker)
  local layout_name = picker.resolved_layout and picker.resolved_layout.preset
  if layout_name then
    local idx = vim.iter(preferred):enumerate():filter(function(_, v) return v == layout_name end):next()
    idx = idx % #preferred + 1
    picker:set_layout(preferred[idx])
  end
end

local function set_prev_preferred_layout(picker)
  local layout_name = picker.resolved_layout and picker.resolved_layout.preset
  if layout_name then
    local idx = vim.iter(preferred):enumerate():filter(function(_, v) return v == layout_name end):next()
    idx = idx == 1 and #preferred or idx - 1
    picker:set_layout(preferred[idx])
  end
end

---@param current_file string current file to exclude
---@param cwd? boolean|string filter current working directory
---@return snacks.picker.Item[]
local function recent_files(current_file, cwd)
  return vim
    .iter(vim.g.VISITEDFILES or {})
    :filter(function(file)
      if cwd then
        return vim.startswith(file, vim.uv.cwd() .. '/')
      end
      return true
    end)
    :filter(function(file) return file ~= current_file end)
    :map(function(file) return { file = file, text = file } end)
    :totable()
end

---@param opts snacks.picker.recent.Config
local function recent(opts)
  local cwd = opts and opts.filter and opts.filter.cwd
  local current_file = vim.fn.resolve(vim.fn.expand('%:p'))
  Snacks.picker.pick(vim.tbl_extend('force', opts or {}, {
    title = 'Recent Files',
    ---@param opts snacks.picker.recent.Config
    ---@type snacks.picker.finder
    finder = function(opts, ctx) return ctx.filter:filter(recent_files(current_file, cwd)) end,
    format = 'file',
    actions = {
      ---@param picker snacks.Picker
      remove = function(picker)
        picker.preview:reset()
        local items = picker:selected({ fallback = true })
        vim.g.VISITEDFILES = vim
          .iter(vim.g.VISITEDFILES or {})
          :filter(function(file)
            return not vim.tbl_contains(items, function(item) return item.file == file end, { predicate = true })
          end)
          :totable()
        picker.list:set_selected()
        picker.list:set_target()
        picker:find()
      end,
    },
    win = { input = { keys = { ['<c-x>'] = { 'remove', mode = { 'i', 'n' } } } } },
  }))
end

return {
  'snacks.nvim',
  keys = {
    { '<leader>gd', false },
    { '<c-p>', function() Snacks.picker.files() end, desc = 'Find Files' },
    { '<c-f>', function() Snacks.picker.grep() end, desc = 'Find Files' },
    { '<leader>,', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>/', function() Snacks.picker.grep() end, desc = 'Grep (Root Dir)' },
    { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
    { '<leader><space>', function() Snacks.picker.files() end, desc = 'Find Files (Root Dir)' },
    -- find
    { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>fB', function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = 'Buffers (all)' },
    { '<leader>fc', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end, desc = 'Find Config File' },
    { '<leader>ff', function() Snacks.picker.files() end, desc = 'Find Files (Root Dir)' },
    { '<leader>fF', function() Snacks.picker.files({ root = false }) end, desc = 'Find Files (cwd)' },
    { '<leader>fg', function() Snacks.picker.git_files() end, desc = 'Find Files (git-files)' },
    { '<leader>fr', function() recent({ filter = { cwd = true } }) end, desc = 'Recent (cwd)' },
    { '<leader>fR', function() recent({ filter = { cwd = false } }) end, desc = 'Recent' },
    { '<leader>fp', function() Snacks.picker.projects() end, desc = 'Projects' },
    -- git
    { '<leader>gh', function() Snacks.picker.git_diff() end, desc = 'Git Diff (hunks)' },
    { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
    { '<leader>gS', function() Snacks.picker.git_stash() end, desc = 'Git Stash' },
    -- Grep
    { '<leader>sb', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
    { '<leader>sB', function() Snacks.picker.grep_buffers() end, desc = 'Grep Open Buffers' },
    { '<leader>sg', function() Snacks.picker.grep() end, desc = 'Grep (Root Dir)' },
    { '<leader>sG', function() Snacks.picker.grep({ root = false }) end, desc = 'Grep (cwd)' },
    { '<leader>sp', function() Snacks.picker.lazy() end, desc = 'Search for Plugin Spec' },
    {
      '<leader>sw',
      function() Snacks.picker.grep_word() end,
      desc = 'Visual selection or word (Root Dir)',
      mode = { 'n', 'x' },
    },
    {
      '<leader>sW',
      function() Snacks.picker.grep_word({ root = false }) end,
      desc = 'Visual selection or word (cwd)',
      mode = { 'n', 'x' },
    },
    -- search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = 'Registers' },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = 'Search History' },
    { '<leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
    { '<leader>sc', function() Snacks.picker.command_history() end, desc = 'Command History' },
    { '<leader>sC', function() Snacks.picker.commands() end, desc = 'Commands' },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
    { '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, desc = 'Buffer Diagnostics' },
    { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help Pages' },
    { '<leader>sH', function() Snacks.picker.highlights() end, desc = 'Highlights' },
    { '<leader>sI', function() Snacks.picker.icons() end, desc = 'Icons' },
    { '<leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
    { '<leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
    { '<leader>sM', function() Snacks.picker.man() end, desc = 'Man Pages' },
    { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
    { '<leader>s.', function() Snacks.picker.resume() end, desc = 'Resume' },
    { '<leader>sq', function() Snacks.picker.qflist() end, desc = 'Quickfix List' },
    { '<leader>su', function() Snacks.picker.undo() end, desc = 'Undotree' },
    -- ui
    { '<leader>uC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },
  },
  opts = {
    ---@type snacks.picker.Config
    picker = {
      enabled = true,
      ui_select = true,
      prompt = '',
      formatters = {
        file = {
          filename_first = true,
          truncate = 100,
        },
      },
      sources = {
        grep_word = { layout = { preset = 'telescope_preview' } },
        grep = { layout = { preset = 'telescope_preview' } },
        lsp_references = { layout = { preset = 'telescope_preview' } },
        lsp_definitions = { layout = { preset = 'telescope_preview' } },
        jumps = { layout = { preset = 'telescope_vertical' } },
        colorschemes = { layout = { preset = 'ivy' } },
        git_diff = { layout = { preset = 'telescope_preview' } },
        git_status = { layout = { preset = 'telescope_preview' } },
        agent_terminals = { layout = { preset = 'telescope_vertical' } },
        keymaps = { layout = { preset = 'telescope_preview' } },
      },
      layouts = {
        telescope_no_preview = telescope_no_preview,
        telescope_preview = telescope_preview,
        telescope_vertical = telescope_vertical,
      },
      layout = 'vertical',
      actions = {
        trouble_open = function(...) return require('trouble.sources.snacks').actions.trouble_open.action(...) end,
        cycle_next_layouts = function(picker) set_next_preferred_layout(picker) end,
        cycle_prev_layouts = function(picker) set_prev_preferred_layout(picker) end,
        flash = function(picker)
          require('flash').jump({
            pattern = '^',
            label = { after = { 0, 0 } },
            search = {
              mode = 'search',
              exclude = {
                function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'snacks_picker_list' end,
              },
            },
            action = function(match)
              local idx = picker.list:row2idx(match.pos[1])
              picker.list:_move(idx, true, true)
            end,
          })
        end,
      },
      win = {
        input = {
          keys = {
            ['<c-h>'] = { 'cycle_next_layouts', mode = { 'i', 'n' } },
            ['<c-l>'] = { 'cycle_prev_layouts', mode = { 'i', 'n' } },
            ['<c-t>'] = { 'trouble_open', mode = { 'n', 'i' } },
            ['<c-s>'] = { 'flash', mode = { 'n', 'i' } },
            ['<c-c>'] = { 'close', mode = { 'n', 'i' } },
            ['<c-u>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
            ['<c-d>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
            ['s'] = { 'flash' },
          },
        },
        list = {
          keys = {
            ['<c-u>'] = { 'preview_scroll_up' },
            ['<c-d>'] = { 'preview_scroll_down' },
          },
        },
      },
    },
  },
}
