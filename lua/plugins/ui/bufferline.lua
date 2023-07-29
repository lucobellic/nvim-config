return {
  'akinsho/bufferline.nvim',
  dependencies = {
    'echasnovski/mini.bufremove',
  },
  keys = {
    { '<S-h>',      false },
    { '<S-l>',      false },
    { '<C-h>',      ':BufferLineCyclePrev<cr>',                                desc = 'Buffer Previous' },
    { '<C-l>',      ':BufferLineCycleNext<cr>',                                desc = 'Buffer Next' },
    { '<A-h>',      ':BufferLineMovePrev<cr>',                                 desc = 'Buffer Move Previous' },
    { '<A-l>',      ':BufferLineMoveNext<cr>',                                 desc = 'Buffer Move Next' },
    { '<A-p>',      ':BufferLineTogglePin<cr>',                                desc = 'Buffer Pin' },
    { '<C-1>',      ':BufferLineGoToBuffer 1<cr>',                             desc = 'Buffer 1' },
    { '<C-2>',      ':BufferLineGoToBuffer 2<cr>',                             desc = 'Buffer 2' },
    { '<C-3>',      ':BufferLineGoToBuffer 3<cr>',                             desc = 'Buffer 3' },
    { '<C-4>',      ':BufferLineGoToBuffer 4<cr>',                             desc = 'Buffer 4' },
    { '<C-5>',      ':BufferLineGoToBuffer 5<cr>',                             desc = 'Buffer 5' },
    { '<C-6>',      ':BufferLineGoToBuffer 6<cr>',                             desc = 'Buffer 6' },
    { '<C-7>',      ':BufferLineGoToBuffer 7<cr>',                             desc = 'Buffer 7' },
    { '<C-8>',      ':BufferLineGoToBuffer 8<cr>',                             desc = 'Buffer 8' },
    { '<C-9>',      ':BufferLineGoToBuffer 9<cr>',                             desc = 'Buffer 9' },
    { '<C-0>',      ':BufferLast<cr>',                                         desc = 'Buffer Last' },
    { '<C-/>',      ':BufferLinePick<cr>',                                     desc = 'Buffer Pick' },
    { '<leader>bf', ':BufferLineSortByRelativeDirectory<cr>',                  desc = 'Buffer Order By Directory' },
    { '<leader>bl', ':BufferLineSortByExtension<cr>',                          desc = 'Buffer Order By Language' },
    { '<C-q>',      function() require('mini.bufremove').delete(0, false) end, desc = 'Delete Buffer' },
  },
  opts = {
    options = {
      themable = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      show_tab_indicators = true,
      modified_icon = '',
      always_show_bufferline = true,

      -- separator_style = "slant" | "slope" | "thick" | "thin" | { 'any', 'any' },
      -- separator_style = {'', ''},
      separator_style = 'slope',
      indicator = {
        icon = '▎',
        style = 'none'
      },
      offsets = {
        {
          filetype = "neo-tree",
          text = "File Explorer",
          text_align = "center",
          separator = false,
        }
      },
      diagnostics = false,
      diagnostics_update_in_insert = false,
    }
  },
}
