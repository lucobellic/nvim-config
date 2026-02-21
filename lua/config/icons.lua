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
  kinds           = {
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
