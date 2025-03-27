-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
---@type LazySpec
return {
  'AstroNvim/astrocore',
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = false,
      cmp = true,
      diagnostics = { virtual_text = false, virtual_lines = false },
      highlighturl = true,
      notifications = true,
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = {
        backup = false,
        conceallevel = 2,
        laststatus = 3,
        number = false,
        numberwidth = 1,
        pumblend = 0,
        relativenumber = false,
        incsearch = false,
        showbreak = '↪',
        signcolumn = 'yes:2',
        spell = false,
        splitkeep = 'screen',
        swapfile = false,
        timeout = false,
        undofile = true,
        winblend = 0,
        wrap = false,
        writebackup = false,
        sessionoptions = {
          'buffers',
          'curdir',
          'folds',
          'globals',
          'help',
          'skiprtp',
          'tabpages',
          'terminal',
          'winpos',
          'winsize',
        },
        listchars = {
          tab = ' ',
          trail = '·',
          extends = '',
          precedes = '',
        },
        diffopt = {
          'internal',
          'filler',
          'closeoff',
        },
        fillchars = {
          diff = '╱',
          eob = ' ',
          stl = ' ',
          stlnc = ' ',
          wbr = ' ',
          horiz = '─',
          horizup = '┴',
          horizdown = '┬',
          vert = '│',
          vertleft = '┤',
          vertright = '├',
          verthoriz = '┼',
        },
      },
      g = {
        ai_cmp = false,
        autoformat = false,
        suggestions = 'copilot',
        winborder = 'single',
      },
    },
    -- Mappings can be configured through AstroCore as well.
    mappings = {
      n = {
        --- Disable default keymap in favor of personal ones
        ['<Leader>e'] = false,
        ['<Leader>fr'] = false,
        ['<F7>'] = false,
        ['<Leader>o'] = false,
      }
    },
    autocmds = {
      cpp_comment = {
        {
          event = { 'FileType' },
          pattern = { 'cpp' },
          command = 'setlocal commentstring=//\\ %s',
          desc = 'Set // as default comment string for c++',
        },
      },
      terminal_options = {
        {
          event = { 'TermOpen' },
          pattern = { '*' },
          callback = function()
            vim.b.minianimate_disable = true
            vim.b.miniindentscope_disable = true
            vim.opt_local.spell = false
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
          end,
          desc = 'Set terminal buffer options',
        },
      },
      cursor_line = {
        {
          event = { 'WinEnter' },
          pattern = '*',
          callback = function(ev) vim.api.nvim_set_option_value('cursorline', true, { win = ev.win }) end,
          desc = 'Display cursorline only in focused window',
        },
        {
          event = { 'WinLeave' },
          pattern = '*',
          callback = function(ev)
            local current_filetype = vim.api.nvim_get_option_value('filetype', { buf = ev.buf }):lower()
            local ignored_list = { 'neo-tree', 'outline' }
            if
                not vim.tbl_contains(ignored_list, function(ft) return ft == current_filetype end, { predicate = true })
            then
              vim.api.nvim_set_option_value('cursorline', false, { win = ev.win })
            end
          end,
          desc = 'Hide cursorline when leaving window',
        },
      },
      repeat_change = {
        {
          event = { 'InsertLeave' },
          pattern = { '*' },
          callback = function()
            if vim.g.change then
              vim.g.change_text = vim.fn.getreg('.')
              vim.fn.setreg('/', vim.fn.getreg('"', 1))
              vim.g.change = false
              vim.fn['repeat#set'](vim.api.nvim_replace_termcodes('<cmd>RepeatChange<cr>', true, false, true))
            end
          end,
        },
      },
      tab_enter = {
        {
          event = { 'TabEnter' },
          pattern = { '*' },
          callback = function() require('util.tabpages').focus_first_listed_buffer() end,
        },
      },
    },
    commands = {
      RepeatChange = {
        function() require('plugins.astronvim.util.commands').repeat_change() end,
        desc = 'Repeat last change',
      },
      ToggleDiagnostics = {
        function() require('plugins.astronvim.util.commands').toggle_diagnostics() end,
        desc = 'Toggle diagnostics',
      },
      ToggleDiagnosticVirtualLines = {
        function() require('plugins.astronvim.util.commands').toggle_diagnostic_virtual_lines() end,
        desc = 'Toggle diagnostic virtual lines',
      },
      ToggleDiagnosticVirtualText = {
        function() require('plugins.astronvim.util.commands').toggle_diagnostic_virtual_text() end,
        desc = 'Toggle diagnostic virtual text',
      },
      ToggleDiagnosticUnderline = {
        function() require('plugins.astronvim.util.commands').toggle_diagnostic_underline() end,
        desc = 'Toggle diagnostic virtual text',
      },
    },
  },
}
