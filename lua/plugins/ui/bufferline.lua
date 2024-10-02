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

return {
  'akinsho/bufferline.nvim',
  enabled = vim.env.KITTY_SCROLLBACK_NVIM ~= 'true',
  event = 'BufEnter',
  dependencies = {
    { 'echasnovski/mini.bufremove' },
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
    { '<c-/>', '<cmd>BufferLinePick<cr>', desc = 'Buffer Pick' },
    { '<leader>bf', '<cmd>BufferLineSortByRelativeDirectory<cr>', desc = 'Buffer Order By Directory' },
    { '<leader>bl', '<cmd>BufferLineSortByExtension<cr>', desc = 'Buffer Order By Language' },
    {
      '<C-q>',
      function() require('mini.bufremove').delete(0, false) end,
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
        themable = true,

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
      highlights = {
        buffer_visible = {
          bg = vim.api.nvim_get_hl(0, { name = 'BufferLineBufferVisible', link = false }).bg,
        },
        buffer_selected = {
          bg = vim.api.nvim_get_hl(0, { name = 'BufferLineBufferSelected', link = false }).bg,
        },
        background = {
          bg = vim.api.nvim_get_hl(0, { name = 'BufferLineBackground', link = false }).bg
            or vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg,
        },
      },
    }
  end,
}
