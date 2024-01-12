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

return {
  'akinsho/bufferline.nvim',
  dependencies = {
    { 'echasnovski/mini.bufremove' },
    {
      'folke/which-key.nvim',
      optional = true,
      opts = {
        defaults = {
          ['<leader>bc'] = { name = '+close' },
        },
      },
    },
  },
  keys = {
    { '<S-h>', false },
    { '<S-l>', false },
    { '<C-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Buffer Previous' },
    { '<C-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Buffer Next' },
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
    { '<C-/>', '<cmd>BufferLinePick<cr>', desc = 'Buffer Pick' },
    { '<leader>bf', '<cmd>BufferLineSortByRelativeDirectory<cr>', desc = 'Buffer Order By Directory' },
    { '<leader>bl', '<cmd>BufferLineSortByExtension<cr>', desc = 'Buffer Order By Language' },
    {
      '<C-q>',
      function() require('mini.bufremove').delete(0, false) end,
      desc = 'Delete Buffer',
    },
    { '<leader>bco', '<cmd>BufferLineCloseOthers<cr>', desc = 'Buffer Line Close Others' },
    { '<leader>bch', '<cmd>BufferLineCloseLeft<cr>', desc = 'Buffer Line Close Left' },
    { '<leader>bcl', '<cmd>BufferLineCloseRight<cr>', desc = 'Buffer Line Close Right' },
    { '<leader>bcp', '<cmd>BufferLinePickClose<cr>', desc = 'Buffer Line Pick Close' },
    { '<leader>bcg', '<cmd>BufferLineGroupClose<cr>', desc = 'Buffer Line Group Close' },
  },
  opts = function()
    local edgy_groups = require('util.edgy.init')
    local right_edgebar = require('edgy.config').layout.right
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

        -- separator_style = "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
        -- separator_style = {'', ''},
        separator_style = 'slope',
        indicator = {
          icon = '▎',
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
          right = function()
            local result = {}
            if right_edgebar.visible ~= 0 then
              for i, group in ipairs(edgy_groups.groups) do
                local title = ' ' .. group.title .. '  '
                if edgy_groups.current_group_index['right'] == i then
                  table.insert(result, { text = '', fg = '#111d2c', bg = 'none' })
                  table.insert(result, { text = title, fg = '#57c1ff', bg = '#111d2c' })
                  table.insert(result, { text = '', fg = '#111d2c', bg = 'none' })
                else
                  table.insert(result, { text = ' ', fg = 'none', bg = 'none' })
                  table.insert(result, { text = title, fg = '#4d5566', bg = 'none' })
                  table.insert(result, { text = ' ', fg = 'none', bg = 'none' })
                end
              end
            end
            return result
          end,
        },
      },
    }
  end,
}
