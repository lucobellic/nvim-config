local function incline_safe_refresh()
  local ok, incline = pcall(require, 'incline')
  if ok then
    incline.refresh()
    vim.defer_fn(function() incline.refresh() end, 200)
    vim.defer_fn(function() incline.refresh() end, 400)
  end
end

local function not_floating(_, win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
end

local function ft_and(ft, fn)
  return function(buf, win) return vim.bo[buf].filetype == ft and fn(buf, win) end
end

local function trouble_mode(mode)
  return function(_, win)
    local t = vim.w[win].trouble
    if type(mode) == 'table' then
      return t and vim.list_contains(mode, t.mode)
    end
    return t and t.mode == mode
  end
end

---@param dst LayoutConfig
---@param src { opts: LayoutConfig }
local function extend(src, dst)
  local src_opts = src.opts or {}
  vim.iter({ 'bottom', 'left', 'right' }):each(function(pos) vim.list_extend(dst[pos], src_opts[pos] or {}) end)
end

return {
  'lucobellic/layout.nvim',
  cond = vim.g.layout == 'layout',
  dev = true,
  lazy = true,
  keys = {
    {
      '<leader>;',
      function() require('layout').pick() end,
      desc = 'Layout Pick',
      mode = { 'n', 'v' },
    },
    {
      '<leader>we',
      function()
        if vim.b.layout then
          local bufnr = vim.api.nvim_win_get_buf(0)
          require('layout').set_buffer_enabled(bufnr, not vim.b.layout.enabled)
          vim.api.nvim_set_option_value('buflisted', not vim.b.layout.enabled, { buf = 0 })
          vim.schedule(function() vim.cmd('wincmd =') end)
        end
      end,
      desc = 'Layout Toggle Attachment',
    },
    { '<leader>wh', '<cmd>Layout close left<cr>', desc = 'Layout Close Left' },
    { '<leader>wl', '<cmd>Layout close right<cr>', desc = 'Layout Close Right' },
    { '<leader>wj', '<cmd>Layout close bottom<cr>', desc = 'Layout Close Bottom' },
  },
  ---@type LayoutConfig
  opts = {
    autosave = {
      panels = true,
      views = false,
    },
    left = {
      size = 0.2,
      {
        name = 'explorer',
        picker = { icon = '', key = 'e' },
        views = {
          {
            name = 'filesystem',
            filter = function(buf)
              return vim.bo[buf].filetype == 'neo-tree' and vim.b[buf].neo_tree_source == 'filesystem'
            end,
            open = 'Neotree show position=left filesystem',
          },
        },
      },
      {
        name = 'diffview',
        picker = { icon = '', key = 'i' },
        views = {
          {
            name = 'diffview-file-panel',
            filter = 'DiffviewFiles',
            open = function()
              local lib = require('diffview.lib')
              local current_view = lib.get_current_view()
              if current_view then
                require('diffview.actions').toggle_files()
              else
                vim.cmd('DiffviewOpen')
              end
            end,
          },
        },
      },
      {
        name = 'symbols',
        views = {
          {
            name = 'aerial',
            filter = 'aerial',
            open = 'AerialToggle',
          },
          {
            name = 'trouble-symbols',
            filter = ft_and('trouble', trouble_mode('symbols')),
            open = 'Trouble symbols toggle focus=false win.position=left',
          },
        },
      },
    },
    right = {
      size = 0.3,
      {
        name = 'search',
        views = {
          {
            name = 'grug-far',
            filter = ft_and('grug-far', not_floating),
          },
        },
      },
      {
        name = 'notes',
        views = {
          {
            name = 'notes',
            filter = function(buf, win)
              return vim.bo[buf].filetype == 'markdown'
                and not_floating(buf, win)
                and vim.api.nvim_buf_get_name(buf):find('/notes/') ~= nil
                and vim.g.edgy_notes_disabled ~= true
            end,
          },
        },
      },
    },
    bottom = {
      size = 0.2,
      align = 'full',
      {
        name = 'noice',
        picker = { icon = '', key = 'n' },
        views = {
          {
            name = 'messages',
            title = 'noice',
            filter = function(buf, win)
              return vim.bo[buf].filetype == 'noice' and not_floating(buf, win) and vim.bo[buf].buftype == 'nofile'
            end,
            open = 'Noice',
          },
        },
      },
    },

    -- TODO: do not work, to be fixed later.
    workspaces = {
      auto_save = false,
      auto_restore = false,
      dir = vim.fn.stdpath('data') .. '/layout',
    },
  },
  ---@param opts LayoutConfig
  config = function(_, opts)
    extend(require('plugins.ui.layout.layout-trouble'), opts)
    extend(require('plugins.ui.layout.layout-term'), opts)
    extend(require('plugins.ui.layout.layout-dap'), opts)
    extend(require('plugins.ui.layout.layout-test'), opts)
    extend(require('plugins.ui.layout.layout-ai'), opts)
    require('layout').setup(opts)
    -- Add autocmd to refresh the statusline when the window is opened
    vim.api.nvim_create_autocmd(
      { 'WinResized' },
      { pattern = { '*' }, callback = function() incline_safe_refresh() end }
    )
  end,
}
