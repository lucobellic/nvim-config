local function incline_safe_refresh()
  local ok, incline = pcall(require, 'incline')
  if ok then
    incline.refresh()
  end
end

local function extend(dst, src)
  local src_opts = src.opts or {}
  for _, pos in ipairs({ 'top', 'bottom', 'left', 'right' }) do
    vim.list_extend(dst[pos], src_opts[pos] or {})
  end
end

return {
  'folke/edgy.nvim',
  keys = {
    {
      '<leader>wl',
      function()
        require('edgy').toggle('right')
        incline_safe_refresh()
      end,
      desc = 'Edgy Toggle Right',
    },
    {
      '<leader>wh',
      function()
        require('edgy').toggle('left')
        incline_safe_refresh()
      end,
      desc = 'Edgy Toggle Left',
    },
    {
      '<leader>wj',
      function()
        require('edgy').toggle('bottom')
        incline_safe_refresh()
      end,
      desc = 'Edgy Toggle Bottom',
    },
  },
  opts = {
    options = {
      bottom = { size = 0.2 },
      left = { size = 40 },
    },
    close_when_all_hidden = false,
    exit_when_last = false,
    icons = {
      closed = '',
      open = '',
    },
    wo = {
      winbar = false,
      spell = false,
    },
    keys = {
      -- close window
      ['q'] = function(win) win:close() end,
      -- hide window
      ['<C-q>'] = false,
      ['<c-q>'] = false,
      -- close sidebar
      ['Q'] = function(win) win.view.edgebar:close() end,
      -- next open window
      ['>w'] = function(win) win:next({ visible = true, focus = true }) end,
      -- previous open window
      ['<w'] = function(win) win:prev({ visible = true, focus = true }) end,
      -- next loaded window
      ['>W'] = function(win) win:next({ pinned = false, focus = true }) end,
      -- prev loaded window
      ['<W'] = function(win) win:prev({ pinned = false, focus = true }) end,
    },
    top = {},
    left = {
      {
        title = 'Neo-Tree',
        ft = 'neo-tree',
        filter = function(buf) return vim.b[buf].neo_tree_source == 'filesystem' end,
        size = { height = 0.5 },
        open = 'Neotree show position=left filesystem',
      },
      {
        title = 'diffview-file-panel',
        ft = 'DiffviewFiles',
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
    right = {
      {
        title = 'codecompanion',
        ft = 'codecompanion',
        filter = function(_, win)
          return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
        end,
        open = 'CodeCompanionChat toggle',
        size = { width = 0.25 },
      },
      { title = 'avante', ft = 'Avante', open = 'AvanteToggle', size = { width = 0.25 } },
      { title = 'avante-files', ft = 'AvanteFiles' },
      { title = 'avante-selected-files', ft = 'AvanteSelectedFiles', size = { height = 0.1 } },
      {
        title = 'avante-input',
        ft = 'AvanteInput',
        filter = function(_, win)
          return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
        end,
        size = { height = 0.2 },
      },
    },
    bottom = {
      {
        title = 'noice',
        ft = 'noice',
        filter = function(buf, win)
          local is_not_floating = vim.api.nvim_win_get_config(win).relative == ''
          local is_no_file = vim.bo[buf].buftype == 'nofile'
          return is_no_file and is_not_floating
        end,
        open = 'Noice',
      },
      {
        title = 'gitlab',
        ft = 'gitlab',
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
      },
    },
    animate = {
      enabled = false,
      cps = 300,
      spinner = {
        frames = { '', '', '', '', '', '' },
      },
    },
  },
  config = function(_, opts)
    extend(opts, require('plugins.ui.edgy.edgy-term'))
    extend(opts, require('plugins.ui.edgy.edgy-trouble'))
    extend(opts, require('plugins.ui.edgy.edgy-test'))
    extend(opts, require('plugins.ui.edgy.edgy-dap'))
    require('edgy').setup(opts)
  end,
}
