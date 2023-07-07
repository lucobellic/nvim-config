return {

  { 'ellisonleao/gruvbox.nvim' },

  {
    url = 'git@github.com:lucobellic/ayugloom.nvim.git',
    name = 'ayugloom',
    dependencies = 'rktjmp/lush.nvim',
    dev = true,
    lazy = true,
  },

  -- Configure LazyVim to load colorscheme
  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'ayugloom',
      icons = {
        dap = {
          Stopped = { ' ', 'DiagnosticWarn', 'DapStoppedLine' }, --  
          Breakpoint = { ' ', 'DiagnosticError' },             -- 󰧞  
          BreakpointCondition = { ' ', 'DiagnosticError' },
          BreakpointRejected = { " ", "DiagnosticError" },
          LogPoint = ".>",
        },
        diagnostics = {
          Error = " ",
          Warn = " ",
          Hint = " ",
          Info = " ",
        },
        git = {
          added = " ",
          modified = " ",
          removed = " ",
        },
        kinds = {
          Array = " ",
          Boolean = " ",
          Class = " ",
          Color = " ",
          Constant = " ",
          Constructor = " ",
          Copilot = " ",
          Enum = " ",
          EnumMember = " ",
          Event = " ",
          Field = " ",
          File = " ",
          Folder = " ",
          Function = " ",
          Interface = " ",
          Key = " ",
          Keyword = " ",
          Method = " ",
          Module = " ",
          Namespace = " ",
          Null = " ",
          Number = " ",
          Object = " ",
          Operator = " ",
          Package = " ",
          Property = " ",
          Reference = " ",
          Snippet = " ",
          String = " ",
          Struct = " ",
          Text = " ",
          TypeParameter = " ",
          Unit = " ",
          Value = " ",
          Variable = " ",
        },
      }
    },
  }
}
