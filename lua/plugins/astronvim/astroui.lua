-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`

---@type LazySpec
return {
  'AstroNvim/astroui',
  ---@type AstroUIOpts
  opts = {
    colorscheme = 'ayugloom',
    folding = false,
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {},
    lazygit = false,
    -- Icons can be configured throughout the interface
    icons = {
      ActiveLSP              = ' ',
      ActiveTS               = ' ',
      ArrowLeft              = ' ',
      ArrowRight             = ' ',
      Bookmarks              = ' ',
      BufferClose            = ' ',
      DapBreakpoint          = ' ',
      DapBreakpointCondition = ' ',
      DapBreakpointRejected  = ' ',
      DapLogPoint            = ' ',
      DapStopped             = ' ',
      Debugger               = ' ',
      DefaultFile            = ' ',
      Diagnostic             = ' ',
      DiagnosticError        = '┊ ',
      DiagnosticHint         = '┊ ',
      DiagnosticInfo         = '┊ ',
      DiagnosticWarn         = '┊ ',
      Ellipsis               = ' ',
      Environment            = ' ',
      FileNew                = ' ',
      FileModified           = ' ',
      FileReadOnly           = ' ',
      FoldClosed             = ' ',
      FoldOpened             = ' ',
      FoldSeparator          = '  ',
      FolderClosed           = ' ',
      FolderEmpty            = ' ',
      FolderOpen             = ' ',
      Git                    = ' ',
      GitAdd                 = ' ',
      GitBranch              = ' ',
      GitChange              = ' ',
      GitConflict            = ' ',
      GitDelete              = ' ',
      GitIgnored             = ' ',
      GitRenamed             = ' ',
      GitSign                = '│ ',
      GitStaged              = ' ',
      GitUnstaged            = ' ',
      GitUntracked           = '★ ',
      List                   = ' ',
      LSPLoading1            = ' ',
      LSPLoading2            = '󰀚 ',
      LSPLoading3            = ' ',
      MacroRecording         = ' ',
      Package                = ' ',
      Paste                  = ' ',
      Refresh                = ' ',
      Search                 = ' ',
      Selected               = ' ',
      Session                = ' ',
      Sort                   = ' ',
      Spellcheck             = ' ',
      Tab                    = ' ',
      TabClose               = ' ',
      Terminal               = ' ',
      Window                 = ' ',
      WordFile               = '󰈭 ',
    },
  },
}
