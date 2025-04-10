return {
  'LazyVim/LazyVim',
  opts = {
    colorscheme = vim.g.neovide and 'ayugloom' or 'ayubleak',
    icons = {
      dap = {
        Stopped             = { '', 'String', 'DapStoppedLine' }, --  
        Breakpoint          = { '', 'DiagnosticError' },-- 󰧞   
        BreakpointCondition = { '', 'DiagnosticWarn'  },
        BreakpointRejected  = { '', 'Comment'         },
        LogPoint            = '.>',
      },
      diagnostics = {
        Error = ' ',
        Warn  = ' ',
        Hint  = ' ',
        Info  = ' ',
      },
      git = {
        added    = ' ',
        modified = ' ',
        removed  = ' ',
      },
      kinds = {
        Array         = ' ',
        Boolean       = ' ',
        Class         = ' ',
        Codeium       = '󰘦 ',
        Color         = ' ',
        Control       = ' ',
        Collapsed     = ' ',
        Constant      = ' ',
        Constructor   = ' ',
        Copilot       = ' ',
        Enum          = ' ',
        EnumMember    = ' ',
        Event         = ' ',
        Field         = ' ',
        File          = ' ',
        Folder        = ' ',
        Function      = ' ',
        Interface     = ' ',
        Key           = ' ',
        Keyword       = ' ',
        Method        = ' ',
        Module        = ' ',
        Namespace     = ' ',
        Null          = ' ',
        Number        = ' ',
        Object        = ' ',
        Operator      = ' ',
        Package       = ' ',
        Property      = ' ',
        Reference     = ' ',
        Snippet       = ' ',
        String        = ' ',
        Struct        = ' ',
        Supermaven    = ' ',
        TabNine       = '󰏚 ',
        Text          = ' ',
        TypeParameter = ' ',
        Unit          = ' ',
        Value         = ' ',
        Variable      = ' ',
      },
    },
  },
}
