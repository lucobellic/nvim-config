---@module "trouble"

return {
  'folke/trouble.nvim',
  keys = {
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>cs',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>cL',
      '<cmd>Trouble lsp toggle focus=false win.position=bottom<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
  },
  opts = {
    max_items = 500, -- limit number of items that can be displayed per section
    warn_no_results = false, -- show a warning when there are no results
    open_no_results = true, -- open the trouble window when there are no results
    ---@type trouble.Window.opts
    preview = {
      type = 'main',
      scratch = false,
    },
    ---@type table<string, trouble.Mode>
    modes = {
      lsp_references = {
        restore = true,
        focus = false,
        follow = false,
        auto_refresh = false,
      },
      lsp_definitions = {
        restore = true,
        focus = false,
        follow = false,
        auto_refresh = false,
      },
      lsp = {
        desc = 'LSP definitions, implementations, type definitions and declarations',
        sections = {
          'lsp_definitions',
          'lsp_implementations',
          'lsp_type_definitions',
          'lsp_declarations',
        },
        title = false,
        restore = true,
        focus = false,
        follow = false,
        auto_refresh = false,
      },
      in_out = {
        desc = 'LSP incoming and outgoing calls',
        sections = {
          'lsp_incoming_calls',
          'lsp_outgoing_calls',
        },
        title = false,
        restore = true,
        focus = false,
        follow = false,
        auto_refresh = false,
      },
      lsp_document_symbols = {
        title = false,
        focus = false,
        format = '{kind_icon}{symbol.name} {text:Comment} {pos}',
      },
    },
    -- Key mappings can be set to the name of a builtin action,
    -- or you can define your own custom action.
    ---@type table<string, string|trouble.Action>
    keys = {
      ['?'] = 'help',
      r = 'refresh',
      R = 'toggle_refresh',
      q = 'close',
      o = 'jump_close',
      ['<esc>'] = 'cancel',
      ['<cr>'] = 'jump',
      ['<2-leftmouse>'] = 'jump',
      ['<c-s>'] = 'jump_split',
      ['<c-v>'] = 'jump_vsplit',
      -- go down to next item (accepts count)
      -- j = "next",
      ['}'] = 'next',
      [']]'] = 'next',
      -- go up to prev item (accepts count)
      -- k = "prev",
      ['{'] = 'prev',
      ['[['] = 'prev',
      i = 'inspect',
      p = 'preview',
      P = 'toggle_preview',
      l = 'fold_open',
      L = 'fold_open_all',
      h = 'fold_close',
      H = 'fold_close_all',
    },
    icons = {},
  },
}
