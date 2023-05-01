require('scrollbar').setup({
  show = true,
  show_in_active_only = false,
  set_highlights = true,
  handle = {
    text = " ",
    color = nil,
    color_nr = nil,
    highlight = "Visual",
    hide_if_all_visible = true
  },
  marks = {
    Search = {
      text = { '│', '│' },
      priority = 0,
      color = nil,
      cterm = nil,
      highlight = "GitSignsDelete",
    },
    Error = {
      text = { '│', '│' },
      priority = 1,
      color = nil,
      cterm = nil,
      highlight = "DiagnosticVirtualTextError",
    },
    Warn = {
      text = { '│', '│' },
      priority = 2,
      color = nil,
      cterm = nil,
      highlight = "DiagnosticVirtualTextWarn",
    },
    Info = {
      text = { '│', '│' },
      priority = 3,
      color = nil,
      cterm = nil,
      highlight = "DiagnosticVirtualTextInfo",
    },
    Hint = {
      text = { '│', '│' },
      priority = 4,
      color = nil,
      cterm = nil,
      highlight = "DiagnosticVirtualTextHint",
    },
    Misc = {
      text = { '│', '│' },
      priority = 5,
      color = nil,
      cterm = nil,
      highlight = "Normal",
    },
    GitAdd = {
      text = { '│', '│' },
      priority = 5,
      color = nil,
      cterm = nil,
      highlight = "GitGutterAdd",
    },
    GitDelete = {
      text = { '│', '│' },
      priority = 5,
      color = nil,
      cterm = nil,
      highlight = "GitGutterDelete",
    },
    GitChange = {
      text = { '│', '│' },
      priority = 5,
      color = nil,
      cterm = nil,
      highlight = "GitGutterChange",
    },
  },
  excluded_buftypes = {
    "terminal",
  },
  excluded_filetypes = {
    "prompt",
    "TelescopePrompt",
    "cmp_menu",
    "cmp_docs"
  },
  handlers = {
    cursor = false,
    diagnostic = true,
    gitsigns = false,
    handle = true,
    search = false,
    ale = false,
  }
})

local gitsign = require('gitsigns')
local gitsign_hunks = require('gitsigns.hunks')

local colors_type = {
  add = 'GitAdd',
  delete = 'GitDelete',
  change = 'GitChange',
  changedelete = 'GitChange'
}

local add_git_signs = function(bufnr)
  local nb_lines = vim.api.nvim_buf_line_count(bufnr)
  local lines = {}
  local hunks = gitsign.get_hunks(bufnr)

  for _, hunk in ipairs(hunks or {}) do
    hunk.vend = math.min(hunk.added.start, hunk.removed.start) + hunk.added.count + hunk.removed.count
    local signs = gitsign_hunks.calc_signs(hunk, 0, nb_lines)
    for _, sign in ipairs(signs) do
      table.insert(lines, {
        line = sign.lnum,
        type = colors_type[sign.type]
      })
    end
  end
  return lines
end

-- require('scrollbar.handlers').register('git', add_git_signs)
