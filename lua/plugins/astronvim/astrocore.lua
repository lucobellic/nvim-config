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
        relativenumber = false,
        number = false,
        spell = false,
        signcolumn = 'yes:2',
        wrap = false,
        showbreak = '↪',
        backup = false,
        writebackup = false,
        swapfile = false,
        undofile = true,
        laststatus = 3,
      },
      g = {
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        autoformat = false,
        ai_cmp = false,
        winborder = 'single',
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- Command mode
      c = {
        ['<esc>'] = { '<C-c>', desc = 'Exit insert mode' },
      },
      -- Normal mode mappings
      n = {
        ['<Leader>e'] = false,

        -- Map <leader>w to <c-w>
        ['<Leader>w'] = { '<c-w>', remap = true },

        -- Save file
        ['<C-s>'] = { '<cmd>w<cr><esc>', desc = 'Save file' },

        -- Replace operations
        ['<Leader>rr'] = { function() vim.fn.feedkeys(':%s/', 't') end, desc = 'Replace' },
        ['<Leader>rw'] = {
          function() return ':%s/' .. vim.fn.expand('<cword>') .. '//g<left><left>' end,
          desc = 'Replace word under cursor',
          expr = true,
        },

        -- Remap > to ] and < to [
        ['>'] = { ']', desc = 'Next', remap = true },
        ['<'] = { '[', desc = 'Prev', remap = true },

        -- Toggle options
        ['<Leader>ua'] = {
          function() vim.g.minianimate_disable = not vim.g.minianimate_disable end,
          desc = 'Toggle Mini Animate',
        },
        ['<Leader>uS'] = { '<cmd>ToggleAutoSave<cr>', desc = 'Toggle Autosave' },
        ['<Leader>uz'] = { '<cmd>TransparencyToggle<cr>', desc = 'Transparency Toggle' },
        ['<Leader>udd'] = { function() vim.cmd('ToggleDiagnosticVirtualText') end, desc = 'Toggle Virtual Text' },
        ['<Leader>udl'] = { function() vim.cmd('ToggleDiagnosticVirtualLines') end, desc = 'Toggle Virtual Lines' },
        ['<Leader>udt'] = { function() vim.cmd('ToggleDiagnostics') end, desc = 'Toggle Diagnostics' },
        ['<Leader>ul'] = { function() vim.o.number = not vim.o.number end, desc = 'Toggle line numbers' },
        ['<Leader>ue'] = {
          function()
            local cmp = require('cmp')
            local current_setting = cmp.get_config().completion.autocomplete
            if current_setting and #current_setting > 0 then
              cmp.setup({ completion = { autocomplete = false } })
              vim.notify('Disabled auto completion', vim.log.levels.WARN, { title = 'Options' })
            else
              cmp.setup({ completion = { autocomplete = { cmp.TriggerEvent.TextChanged } } })
              vim.notify('Enabled auto completion', vim.log.levels.INFO, { title = 'Options' })
            end
          end,
          desc = 'Toggle Auto Completion',
        },
        ['<Leader>uW'] = {
          function()
            require('windows.autowidth').toggle()
            local is_enabled = require('windows.config').autowidth.enable
            local text = is_enabled and 'Enabled' or 'Disabled'
            local level = is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
            vim.notify(text .. ' autowidth', level, { title = 'Options' })
          end,
          desc = 'Windows Toggle Autowidth',
        },
        ['<Leader>uh'] = {
          function()
            local is_enabled = vim.lsp.inlay_hint.is_enabled()
            vim.lsp.inlay_hint.enable(not is_enabled)
            local text = (not is_enabled and 'Enabled' or 'Disabled') .. ' inlay hints'
            local level = not is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
            vim.notify(text, level, { title = 'Options' })
          end,
          desc = 'Toggle Inlay Hints',
        },

        -- Quit mappings
        ['<Leader>qq'] = { '<cmd>qa!<cr>', desc = 'Quit all' },
        ['<Leader>qa'] = { '<cmd>qa!<cr>', desc = 'Quit all' },
        ['<Leader>qu'] = {
          function()
            vim
              .iter(vim.api.nvim_list_uis())
              :filter(function(ui) return ui.chan and not ui.stdout_tty end)
              :each(function(ui) vim.fn.chanclose(ui.chan) end)
          end,
          desc = 'Quit UIs',
        },

        -- Tabs
        ['<S-up>'] = { '<cmd>tabnext<cr>', desc = 'Tab Next' },
        ['<S-down>'] = { '<cmd>tabprev<cr>', desc = 'Tab Prev' },
        ['<C-t>'] = { '<cmd>tabnew<cr>', desc = 'Tab New' },
        ['gq'] = { '<cmd>tabclose<cr>', desc = 'Tab Close' },
        ['<A-j>'] = {
          function() require('util.tabpages').move_buffer_to_tab('prev', true) end,
          desc = 'Move buffer to prev tab',
        },
        ['<A-k>'] = {
          function() require('util.tabpages').move_buffer_to_tab('next', true) end,
          desc = 'Move buffer to next tab',
        },

        -- Window resizing
        ['<c-left>'] = {
          function()
            local get_edgy_window = function(winnr)
              local ok, EdgyWindow = pcall(require, 'edgy.window')
              return ok and EdgyWindow.cache[vim.fn.win_getid(winnr)] or nil
            end
            local right_edgy = get_edgy_window(vim.fn.winnr('l'))
            if right_edgy then
              right_edgy:resize('width', 5)
            else
              require('smart-splits').resize_left()
            end
          end,
          desc = 'Resize left',
        },
        ['<c-right>'] = {
          function()
            local get_edgy_window = function(winnr)
              local ok, EdgyWindow = pcall(require, 'edgy.window')
              return ok and EdgyWindow.cache[vim.fn.win_getid(winnr)] or nil
            end
            local right_edgy = get_edgy_window(vim.fn.winnr('l'))
            if right_edgy then
              right_edgy:resize('width', -5)
            else
              require('smart-splits').resize_right()
            end
          end,
          desc = 'Resize right',
        },
        ['<c-up>'] = {
          function()
            local get_edgy_window = function(winnr)
              local ok, EdgyWindow = pcall(require, 'edgy.window')
              return ok and EdgyWindow.cache[vim.fn.win_getid(winnr)] or nil
            end
            local down_edgy = get_edgy_window(vim.fn.winnr('j'))
            if down_edgy then
              down_edgy:resize('height', 5)
            else
              require('smart-splits').resize_up()
            end
          end,
          desc = 'Resize up',
        },
        ['<c-down>'] = {
          function()
            local get_edgy_window = function(winnr)
              local ok, EdgyWindow = pcall(require, 'edgy.window')
              return ok and EdgyWindow.cache[vim.fn.win_getid(winnr)] or nil
            end
            local down_edgy = get_edgy_window(vim.fn.winnr('j'))
            if down_edgy then
              down_edgy:resize('height', -5)
            else
              require('smart-splits').resize_down()
            end
          end,
          desc = 'Resize down',
        },

        -- Copy all
        ['<Leader>A'] = { '<cmd>silent %y+<cr>', desc = 'Copy all' },

        -- Indent
        ['>>'] = { '>>', desc = 'Increase Indent' },
        ['<<'] = { '<<', desc = 'Decrease Indent' },

        -- Copilot
        ['<Leader>cp'] = { '<cmd>Copilot panel<cr>', desc = 'Copilot Panel' },

        -- Jupytext
        ['<Leader>njs'] = { function() require('util.jupytext').sync() end, desc = 'Jupytext Sync' },
        ['<Leader>njp'] = { function() require('util.jupytext').pair() end, desc = 'Jupytext Pair' },
        ['<Leader>njc'] = { function() require('util.jupytext').to_notebook() end, desc = 'Jupytext Convert' },
        ['<Leader>njl'] = { function() require('util.jupytext').to_paired_notebook() end, desc = 'Jupytext Link' },

        -- Change with tracking
        ['c'] = { '<cmd>lua vim.g.change = true<cr>c', desc = 'Change' },
      },
      -- Visual mode mappings
      v = {
        -- Search and replace
        ['/'] = { '"hy/<C-r>h', desc = 'Search word' },
        ['<Leader>rr'] = { function() vim.fn.feedkeys(':s/', 't') end, desc = 'Replace Visual' },

        -- Save file
        ['<C-s>'] = { '<cmd>w<cr><esc>', desc = 'Save file' },

        -- Remap > to ] and < to [
        ['>'] = { ']', desc = 'Next', remap = true },
        ['<'] = { '[', desc = 'Prev', remap = true },

        -- Indent
        ['>>'] = { '>>', desc = 'Increase Indent' },
        ['<<'] = { '<<', desc = 'Decrease Indent' },

        -- Change with tracking
        ['c'] = { '<cmd>lua vim.g.change = true<cr>c', desc = 'Change' },
      },
      -- Terminal mode mappings
      t = {
        ['<esc>'] = { '<c-\\><c-n>', desc = 'Enter Normal Mode' },
      },
      -- Operator-pending mappings
      o = {
        ['>'] = { ']', desc = 'Next', remap = true },
        ['<'] = { '[', desc = 'Prev', remap = true },
      },
      -- Additional mode mappings
      x = {
        ['>'] = { ']', desc = 'Next', remap = true },
        ['<'] = { '[', desc = 'Prev', remap = true },
      },
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
              change_text = vim.fn.getreg('.')
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
    },
  },
}
