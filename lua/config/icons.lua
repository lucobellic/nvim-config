--- Shared icons and config module (replaces LazyVim.config globals)
local M = {}

-- stylua: ignore
M.icons = {
  misc = {
    dots = '󰇘',
  },
  ft = {
    octo = ' ',
    gh = ' ',
    ['markdown.gh'] = ' ',
  },
  dap = {
    Stopped             = { '', 'String', 'DapStoppedLine' },  --  
    Breakpoint          = { '', 'DiagnosticError' }, -- 󰧞    
    BreakpointCondition = { '', 'DiagnosticWarn'  },
    BreakpointRejected  = { '', 'Comment'         },
    LogPoint            = { '', 'DiagnosticInfo'  }
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
    Call              = ' ',
    CaseStatement     = ' ',
    ContinueStatement = ' ',
    Declaration       = ' ',
    Delete            = ' ',
    DoStatement       = ' ',
    Element           = ' ',
    ForStatement      = ' ',
    GotoStatement     = ' ',
    H1Marker          = '󰉫 ',
    H2Marker          = '󰉬 ',
    H3Marker          = '󰉭 ',
    H4Marker          = '󰉮 ',
    H5Marker          = '󰉯 ',
    H6Marker          = '󰉰 ',
    Identifier        = ' ',
    IfStatement       = ' ',
    List              = ' ',
    Log               = ' ',
    Lsp               = ' ',
    Macro             = ' ',
    MarkdownH1        = '󰉫 ',
    MarkdownH2        = '󰉬 ',
    MarkdownH3        = '󰉭 ',
    MarkdownH4        = '󰉮 ',
    MarkdownH5        = '󰉯 ',
    MarkdownH6        = '󰉰 ',
    Pair              = ' ',
    Regex             = ' ',
    Repeat            = ' ',
    Return            = ' ',
    RuleSet           = ' ',
    Scope             = ' ',
    Specifier         = ' ',
    Statement         = ' ',
    SwitchStatement   = ' ',
    Table             = ' ',
    Terminal          = ' ',
    Type              = ' ',
    WhileStatement    = ' ',
    Array             = ' ',
    BlockMappingPair  = ' ',
    Boolean           = ' ',
    BreakStatement    = ' ',
    Class             = ' ',
    Codeium           = '󰘦 ',
    Collapsed         = ' ',
    Color             = ' ',
    Constant          = ' ',
    Constructor       = ' ',
    Control           = ' ',
    Copilot           = ' ',
    Enum              = ' ',
    EnumMember        = ' ',
    Event             = ' ',
    Field             = ' ',
    File              = ' ',
    Folder            = ' ',
    Function          = ' ',
    Interface         = ' ',
    Key               = ' ',
    Keyword           = ' ',
    Method            = ' ',
    Module            = ' ',
    Namespace         = ' ',
    Null              = ' ',
    Number            = ' ',
    Object            = ' ',
    Operator          = ' ',
    Package           = ' ',
    Property          = ' ',
    Reference         = ' ',
    Snippet           = ' ',
    String            = ' ',
    Struct            = ' ',
    Supermaven        = ' ',
    TabNine           = '󰏚 ',
    Text              = ' ',
    TypeParameter     = ' ',
    Unit              = ' ',
    Value             = ' ',
    Variable          = ' ',
  },
}

M.kind_filter = {
  default = {
    'Class',
    'Constructor',
    'Enum',
    'Field',
    'Function',
    'Interface',
    'Method',
    'Module',
    'Namespace',
    'Package',
    'Property',
    'Struct',
    'Trait',
  },
  markdown = false,
  help = false,
  lua = {
    'Class',
    'Constructor',
    'Enum',
    'Field',
    'Function',
    'Interface',
    'Method',
    'Module',
    'Namespace',
    -- 'Package', -- remove package since luals uses it for control flow structures
    'Property',
    'Struct',
    'Trait',
  },
}

--- Get kind filter for a given buffer
---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  if type(M.kind_filter[ft]) == 'table' then
    return M.kind_filter[ft]
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return type(M.kind_filter) == 'table' and type(M.kind_filter.default) == 'table' and M.kind_filter.default or nil
end

return M
