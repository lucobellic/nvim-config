return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>nb', group = 'bookmarks' },
      },
    },
  },
  {
    dir = vim.fn.stdpath('config') .. '/local/notes',
    name = 'notes',
    event = { 'User LazyBufEnter' },
    keys = {
      { '<leader>na', function() require('notes').add_note() end, desc = 'Notes Add' },
      { '<leader>nd', function() require('notes').delete_note() end, desc = 'Notes Delete' },
      { '<leader>nt', function() require('notes').toggle() end, desc = 'Notes Toggle' },
      { '<leader>ns', function() require('notes').search_notes() end, desc = 'Notes Search (CWD)' },
      { '<leader>nS', function() require('notes').search_all_notes() end, desc = 'Notes Search (All)' },
      { '<leader>nbs', function() require('notes').select_bookmark() end, desc = 'Notes Select Bookmark' },
      { '<leader>nbn', function() require('notes').create_bookmark() end, desc = 'Notes New Bookmark' },
    },
    ---@type NotesConfig
    opts = {
      extmark = {
        virt_text_pos = 'eol_right_align',
      },
      prefix = '󱙝 ',
      suffix = '   ',
    },
    config = function(_, opts) require('notes').setup(opts) end,
  },
}
