return {
  'nvim-pack/nvim-spectre',
  enabled = false,
  opts = {
    line_sep_start = '╭─────────────────────────────────────────',
    result_padding = '│  ',
    line_sep = '╰─────────────────────────────────────────',
    mapping = {
      ['toggle_multiline'] = {
        map = 'tm',
        cmd = "<cmd>lua require('spectre').change_options('multiline')<CR>",
        desc = 'toggle search multiline',
      },
    },
    find_engine = {
      -- rg is map with finder_cmd
      ['rg'] = {
        cmd = 'rg',
        -- default args
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--smart-case',
          '--line-number',
          '--column',
          '-j4',
        },
        options = {
          ['ignore-case'] = {
            value = '--ignore-case',
            icon = '[I]',
            desc = 'ignore case',
          },
          ['hidden'] = {
            value = '--hidden',
            desc = 'hidden file',
            icon = '[H]',
          },
          ['multiline'] = {
            value = '--multiline',
            desc = 'multiline',
            icon = '[M]',
          },
        },
      },
    },
    highlight = {
      ui = 'Title',
      search = 'Search',
      replace = 'Substitute',
    },
  },
}
