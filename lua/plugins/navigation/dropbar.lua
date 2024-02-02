return {
  'Bekaboo/dropbar.nvim',
  event = 'BufEnter',
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
  },
  keys = {
    {
      '<leader>.',
      function() require('dropbar.api').pick() end,
      desc = 'Pick Dropbar Item',
    },
  },
  opts = {
    general = {
      enable = function(buf, win)
        return not vim.api.nvim_win_get_config(win).zindex
          and vim.bo[buf].buftype == ''
          and vim.bo[buf].buftype ~= 'terminal'
          and vim.api.nvim_buf_get_name(buf) ~= ''
          and not vim.wo[win].diff
      end,
    },
    icons = {
      kinds = {
        symbols = {
          File = ' ',
          Folder = '  ',
        },
      },
      ui = {
        bar = {
          separator = '   ',
          extends = '',
        },
        menu = {
          separator = ' ',
          indicator = '',
        },
      },
    },
    bar = {
      pick = {
        pivots = 'asdfghjkl;qwertyuiopzxcvbnm',
      },
      sources = function(buf, _)
        local sources = require('dropbar.sources')
        local utils = require('dropbar.utils')
        if vim.bo[buf].ft == 'markdown' then
          return {
            sources.path,
            sources.markdown,
          }
        end
        if vim.bo[buf].buftype == 'terminal' then
          return {
            sources.terminal,
          }
        end
        return {
          {
            get_symbols = function(buff, win, cursor)
              local symbols = sources.path.get_symbols(buff, win, cursor)
              return vim.tbl_filter(function(v) return v ~= nil end, { symbols[#symbols - 1], symbols[#symbols] })
            end,
          },
          utils.source.fallback({
            sources.lsp,
            sources.treesitter,
          }),
        }
      end,
    },
    menu = {
      keymaps = {
        ['q'] = '<c-w>q',
        ['<Esc>'] = '<c-w>q',
        ['h'] = '<c-w>q',
        ['<BS>'] = '<c-w>q',
        ['<Del>'] = '<c-w>q',
        ['l'] = function()
          local menu = require('dropbar.utils').menu.get_current()
          if not menu then
            return
          end
          local cursor = vim.api.nvim_win_get_cursor(menu.win)
          local component = menu.entries[cursor[1]]:first_clickable(0)
          if component then
            menu:click_on(component, nil, 1, 'l')
          end
        end,
      },
      preview = false, -- When on, preview the symbol under the cursor on CursorMoved
      scrollbar = {
        enable = true,
        background = false, -- When false, only the scrollbar thumb is shown.
      },
    },
  },
}
