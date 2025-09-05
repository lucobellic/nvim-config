if vim.g.vscode then
  local vscode = require('vscode')

  vim.keymap.set(
    'n',
    '<leader>bch',
    function()
      vscode.eval([[
        const { activeTabGroup } = vscode.window.tabGroups;
        const { tabs, activeTab } = activeTabGroup;

        if (activeTab) {
          tabs.slice(0, tabs.indexOf(activeTab))
            .filter(tab => !tab.isPinned)
            .forEach(tab => vscode.window.tabGroups.close(tab));
        }
      ]])
    end,
    { desc = 'Buffer Line Close Left' }
  )

  vim.keymap.set(
    'n',
    '<leader>bcl',
    function()
      vscode.eval([[
      const { activeTabGroup } = vscode.window.tabGroups;
      const { tabs, activeTab } = activeTabGroup;

      if (activeTab) {
        tabs.slice(tabs.indexOf(activeTab) + 1)
          .filter(tab => !tab.isPinned)
          .forEach(tab => vscode.window.tabGroups.close(tab));
      }
    ]])
    end,
    { desc = 'Buffer Line Close Right' }
  )

  vim.keymap.set(
    'n',
    '<leader>bcv',
    function()
      vscode.eval([[
      const { activeTabGroup } = vscode.window.tabGroups;
      const activeTab = activeTabGroup.activeTab;

      vscode.window.tabGroups.all
        .flatMap(group => group.tabs)
        .filter(tab => tab !== activeTab && !tab.isPinned)
        .forEach(tab => vscode.window.tabGroups.close(tab));
    ]])
    end,
    { desc = 'Buffer Line Close Non Visible' }
  )

  vim.keymap.set(
    'n',
    '<leader>bco',
    function()
      vscode.eval([[
        const { activeTabGroup } = vscode.window.tabGroups;
        const activeTab = activeTabGroup.activeTab;

        vscode.window.tabGroups.all
          .flatMap(group => group.tabs)
          .filter(tab => tab !== activeTab && !tab.isPinned)
          .forEach(tab => vscode.window.tabGroups.close(tab));
      ]])
    end,
    { desc = 'Buffer Line Close Others (Non Pinned)' }
  )

  -- Navigate VSCode tabs
  vim.keymap.set('n', 'H', "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
  vim.keymap.set('n', 'L', "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")
end

--- Check if a buffer is pinned
---@param buf any
local function is_pinned(buf)
  for _, e in ipairs(require('bufferline').get_elements().elements or {}) do
    if e.id == buf.bufnr then
      return require('bufferline.groups')._is_pinned(e)
    end
  end

  return false
end

---@param position Edgy.Pos
local function get_edgy_group_icons(position)
  local result = {}
  local statusline = require('edgy-group.stl').get_statusline(position)
  for _, item in ipairs(statusline) do
    table.insert(result, { text = item })
    table.insert(result, { text = ' ', link = 'Normal' })
  end
  return result
end

local icon_hl_cache = {}

---Set the icon highlight color only for selected buffers
---@param state bufferline.Visibility
---@param base_hl string
---@return string
local function set_icon_highlight(state, _, base_hl)
  local colors = require('bufferline.colors')
  local base_name = 'BufferLine' .. base_hl
  local state_props = {
    [1] = { base_name, { link = 'BufferLineBuffer', hl_group = base_name } },
    [2] = {
      base_name .. 'Inactive',
      { link = 'BufferLineBufferVisible', hl_group = base_name .. 'Inactive' },
    },
    [3] = {
      base_name .. 'Selected',
      {
        fg = colors.get_color({ name = base_hl, attribute = 'fg' }),
        ctermfg = colors.get_color({ name = base_hl, attribute = 'fg', cterm = true }),
        bg = vim.api.nvim_get_hl(0, { name = 'BufferLineBufferSelected', link = false }).bg,
        ctermbg = vim.api.nvim_get_hl(0, { name = 'BufferLineBufferSelected', link = false }).ctermbg,
        hl_group = base_name .. 'Selected',
      },
    },
  }

  local props = state_props[state] or state_props[1]
  local icon_hl = props[1]
  local highlight = props[2]

  if icon_hl_cache[icon_hl] then
    return icon_hl
  end

  require('bufferline.highlights').set(icon_hl, highlight)
  icon_hl_cache[icon_hl] = true
  return icon_hl
end

return {
  'akinsho/bufferline.nvim',
  enabled = not (vim.g.started_by_firenvim or vim.env.KITTY_SCROLLBACK_NVIM == 'true'),
  event = 'BufEnter',
  dependencies = {
    { 'lucobellic/edgy-group.nvim' },
    {
      'folke/which-key.nvim',
      optional = true,
      opts = {
        spec = {
          { '<leader>bc', group = 'close' },
        },
      },
    },
  },
  keys = {
    { '<A-h>', '<cmd>BufferLineMovePrev<cr>', desc = 'Buffer Move Previous' },
    { '<A-l>', '<cmd>BufferLineMoveNext<cr>', desc = 'Buffer Move Next' },
    { '<A-p>', '<cmd>BufferLineTogglePin<cr>', desc = 'Buffer Pin' },
    { '<C-1>', '<cmd>BufferLineGoToBuffer 1<cr>', desc = 'Buffer 1' },
    { '<C-2>', '<cmd>BufferLineGoToBuffer 2<cr>', desc = 'Buffer 2' },
    { '<C-3>', '<cmd>BufferLineGoToBuffer 3<cr>', desc = 'Buffer 3' },
    { '<C-4>', '<cmd>BufferLineGoToBuffer 4<cr>', desc = 'Buffer 4' },
    { '<C-5>', '<cmd>BufferLineGoToBuffer 5<cr>', desc = 'Buffer 5' },
    { '<C-6>', '<cmd>BufferLineGoToBuffer 6<cr>', desc = 'Buffer 6' },
    { '<C-7>', '<cmd>BufferLineGoToBuffer 7<cr>', desc = 'Buffer 7' },
    { '<C-8>', '<cmd>BufferLineGoToBuffer 8<cr>', desc = 'Buffer 8' },
    { '<C-9>', '<cmd>BufferLineGoToBuffer 9<cr>', desc = 'Buffer 9' },
    { '<C-0>', '<cmd>BufferLast<cr>', desc = 'Buffer Last' },
    { 'H', '<cmd>BufferLineCyclePrev<cr>', desc = 'Previous Buffer' },
    { 'L', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '<c-/>', '<cmd>BufferLinePick<cr>', desc = 'Buffer Pick' },
    { '<leader>bf', '<cmd>BufferLineSortByRelativeDirectory<cr>', desc = 'Buffer Order By Directory' },
    { '<leader>bl', '<cmd>BufferLineSortByExtension<cr>', desc = 'Buffer Order By Language' },
    {
      '<C-q>',
      function() require('snacks').bufdelete({ force = true }) end,
      desc = 'Delete Buffer',
    },
    {
      '<leader>bco',
      function()
        local current_buf = vim.fn.bufnr()
        vim.tbl_map(
          function(buf) vim.api.nvim_buf_delete(buf.bufnr, { force = true }) end,
          vim.tbl_filter(
            function(buf) return not is_pinned(buf) and buf.bufnr ~= current_buf end,
            vim.fn.getbufinfo({ buflisted = 1 })
          )
        )
        vim.cmd.redrawtabline()
      end,
      desc = 'Buffer Line Close Others (Non Pinned)',
    },
    { '<leader>bch', '<cmd>BufferLineCloseLeft<cr>', desc = 'Buffer Line Close Left' },
    { '<leader>bcl', '<cmd>BufferLineCloseRight<cr>', desc = 'Buffer Line Close Right' },
    { '<leader>bcp', '<cmd>BufferLinePickClose<cr>', desc = 'Buffer Line Pick Close' },
    { '<leader>bcg', '<cmd>BufferLineGroupClose<cr>', desc = 'Buffer Line Group Close' },
    {
      '<leader>bcv',
      function()
        -- Close all non visible buffers
        for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
          if vim.fn.bufwinid(buf.bufnr) == -1 then
            vim.api.nvim_command('bdelete ' .. buf.bufnr)
          end
        end
      end,
      desc = 'Buffer Line Close Non Visible',
    },
  },
  opts = function()
    return {
      options = {
        custom_filter = function(buf_number)
          if
            vim.bo[buf_number].filetype == 'codecompanion'
            or vim.fn.bufname(buf_number):sub(0, 15) == '[CodeCompanion]'
          then
            return false
          end
          return true
        end,
        themable = true,
        -- color_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        show_tab_indicators = true,
        always_show_bufferline = true,

        modified_icon = '',
        truncate_names = false,
        name_formatter = function(buf)
          local short_name = vim.fn.fnamemodify(buf.name, ':t:r')
          return is_pinned(buf) and '' or short_name
        end,
        tab_size = 0,
        separator_style = { '', '' },
        indicator = {
          icon = '',
          style = 'none',
        },
        offsets = {
          -- {
          --   filetype = "neo-tree",
          --   text = "File Explorer",
          --   text_align = "center",
          --   separator = false,
          -- }
        },
        diagnostics = false,
        diagnostics_update_in_insert = false,
        diagnostics_indicator = nil,
        groups = {
          items = {
            require('bufferline.groups').builtin.pinned:with({ icon = '󱂺' }),
          },
        },
        hover = { enabled = false },
        custom_areas = {
          left = function() return get_edgy_group_icons('left') end,
          right = function() return get_edgy_group_icons('right') end,
        },
      },
    }
  end,
  config = function(_, opts)
    require('bufferline.highlights').set_icon_highlight = set_icon_highlight
    require('bufferline').setup(opts)
  end,
}
