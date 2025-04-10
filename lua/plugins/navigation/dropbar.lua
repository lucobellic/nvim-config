---@return dropbar_t?, number?, dropbar_symbol_t?
local function get_bar_with_opened_component()
  require('dropbar')

  ---@type table<integer, table<integer, dropbar_t>>|nil
  local bars = require('dropbar.utils.bar').get()

  -- From the table of table create only one table where all second id is equal to win
  local current_bar = nil
  for buf, table_bar in pairs(bars or {}) do
    if buf == vim.g.dropbar_current_buffer then
      for win, bar in pairs(table_bar or {}) do
        if win == vim.g.dropbar_current_window then
          current_bar = bar
          break
        end
      end
    end
  end

  local opened_component_id, opened_component = vim
    .iter(ipairs(current_bar and current_bar.components or {}))
    :filter(function(_, component) return component.menu and component.menu.is_opened end)
    :next()

  return current_bar, opened_component_id, opened_component
end

return {
  'Bekaboo/dropbar.nvim',
  vesion = '*',
  enabled = not (vim.g.started_by_firenvim or vim.env.KITTY_SCROLLBACK_NVIM == 'true'),
  event = 'BufEnter',
  dependencies = {
    'nvim-telescope/telescope-fzf-native.nvim',
  },
  keys = {
    {
      '<C-m>',
      function()
        vim.g.dropbar_current_buffer = vim.api.nvim_get_current_buf()
        vim.g.dropbar_current_window = vim.api.nvim_get_current_win()
        require('dropbar.api').pick()
      end,
      desc = 'Dropbar Pick Item',
    },
  },
  opts = {
    icons = {
      kinds = {
        symbols = {
          Array = ' ',
          BlockMappingPair = ' ',
          Boolean = ' ',
          BreakStatement = ' ',
          Call = ' ',
          CaseStatement = ' ',
          Class = ' ',
          Color = ' ',
          Constant = ' ',
          Constructor = ' ',
          ContinueStatement = ' ',
          Copilot = ' ',
          Declaration = ' ',
          Delete = ' ',
          DoStatement = ' ',
          Element = ' ',
          Enum = ' ',
          EnumMember = ' ',
          Event = ' ',
          Field = ' ',
          File = ' ',
          Folder = ' ',
          ForStatement = ' ',
          Function = ' ',
          GotoStatement = ' ',
          H1Marker = '󰉫 ', -- Used by markdown treesitter parser
          H2Marker = '󰉬 ',
          H3Marker = '󰉭 ',
          H4Marker = '󰉮 ',
          H5Marker = '󰉯 ',
          H6Marker = '󰉰 ',
          Identifier = ' ',
          IfStatement = ' ',
          Interface = ' ',
          Keyword = ' ',
          List = ' ',
          Log = ' ',
          Lsp = ' ',
          Macro = ' ',
          MarkdownH1 = '󰉫 ', -- Used by builtin markdown source
          MarkdownH2 = '󰉬 ',
          MarkdownH3 = '󰉭 ',
          MarkdownH4 = '󰉮 ',
          MarkdownH5 = '󰉯 ',
          MarkdownH6 = '󰉰 ',
          Method = ' ',
          Module = ' ',
          Namespace = ' ',
          Null = ' ',
          Number = ' ',
          Object = ' ',
          Operator = ' ',
          Package = ' ',
          Pair = ' ',
          Property = ' ',
          Reference = ' ',
          Regex = ' ',
          Repeat = ' ',
          Return = ' ',
          RuleSet = ' ',
          Scope = ' ',
          Snippet = ' ',
          Specifier = ' ',
          Statement = ' ',
          String = ' ',
          Struct = ' ',
          SwitchStatement = ' ',
          Table = ' ',
          Terminal = ' ',
          Text = ' ',
          Type = ' ',
          TypeParameter = ' ',
          Unit = ' ',
          Value = ' ',
          Variable = ' ',
          WhileStatement = ' ',
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
      enable = function(buf, win)
        return not vim.api.nvim_win_get_config(win).zindex
          and vim.bo[buf].buftype == ''
          and vim.bo[buf].buftype ~= 'terminal'
          and vim.bo[buf].buftype ~= 'dropbar'
          and vim.api.nvim_buf_get_name(buf) ~= ''
          and not vim.wo[win].diff
      end,
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
      win_configs = {
        border = vim.g.winborder,
      },
      keymaps = {
        ['q'] = '<c-w>q',
        ['<Esc>'] = '<c-w>q',
        ['h'] = '<c-w>q',
        ['H'] = function()
          local bar, opened_component_id, opened_component = get_bar_with_opened_component()
          if bar and opened_component and opened_component_id and opened_component_id > 1 then
            opened_component.menu:close()
            opened_component:restore()
            bar:pick(opened_component_id - 1)
            bar:redraw()
          end
        end,
        ['L'] = function()
          local bar, opened_component_id, opened_component = get_bar_with_opened_component()
          if bar and opened_component and opened_component_id and opened_component_id < #bar.components then
            opened_component.menu:close()
            opened_component:restore()
            bar:pick(opened_component_id + 1)
            bar:redraw()
          end
        end,
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
    sources = {
      lsp = {
        valid_symbols = {
          'File',
          'Module',
          'Namespace',
          'Package',
          'Class',
          'Method',
          -- 'Property',
          -- 'Field',
          -- 'Constructor',
          'Enum',
          'Interface',
          'Function',
          -- 'Variable',
          -- 'Constant',
          -- 'String',
          -- 'Number',
          -- 'Boolean',
          -- 'Array',
          'Object',
          -- 'Keyword',
          -- 'Null',
          -- 'EnumMember',
          'Struct',
          'Event',
          -- 'Operator',
          'TypeParameter',
        },
      },
      treesitter = {
        valid_types = {
          -- 'block_mapping_pair',
          -- 'array',
          -- 'boolean',
          -- 'break_statement',
          'call',
          'case_statement',
          'class',
          -- 'constant',
          'constructor',
          -- 'continue_statement',
          -- 'delete',
          -- 'do_statement',
          'element',
          'enum',
          'enum_member',
          'event',
          -- 'for_statement',
          'function',
          -- 'goto_statement',
          -- 'h1_marker',
          -- 'h2_marker',
          -- 'h3_marker',
          -- 'h4_marker',
          -- 'h5_marker',
          -- 'h6_marker',
          -- 'if_statement',
          'interface',
          -- 'keyword',
          'macro',
          'method',
          'namespace',
          -- 'null',
          -- 'number',
          -- 'operator',
          'package',
          -- 'pair',
          -- 'property',
          'reference',
          -- 'repeat',
          -- 'return_statement',
          -- 'rule_set',
          'scope',
          -- 'specifier',
          'struct',
          'switch_statement',
          -- 'table',
          'type',
          'type_parameter',
          -- 'unit',
          'value',
          -- 'variable',
          -- 'while_statement',
          'declaration',
          'field',
          -- 'identifier',
          -- 'object',
          -- 'statement',
        },
      },
    },
  },
}
