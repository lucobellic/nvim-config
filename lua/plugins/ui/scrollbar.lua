local scrollbar_utils = require('scrollbar.utils')
scrollbar_utils.set_highlights = function() end -- Provide full control over highlights


require('scrollbar').setup({
  show = true,
  show_in_active_only = true,
  set_highlights = true,
  handle = {
    text = " ",
    hide_if_all_visible = true
  },
  marks = {
    Cursor = {
      text = "█",  -- ┠ ┡ ┢ ┣ ┤ ┥ ┦ ┧ ┨ ┩ ┪ ┫ ┼ ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋
      priority = 0,
    },
    Search = {
      text = { '│', '│' },
      priority = 0,
    },
    Error = {
      text = { '│', '│' },
      priority = 1,
    },
    Warn = {
      text = { '│', '│' },
      priority = 2,
    },
    Info = {
      text = { ' ', ' ' },
      priority = 10,
    },
    Hint = {
      text = { ' ', ' ' },
      priority = 10,
    },
    Misc = {
      text = { ' ', ' ' },
      priority = 10,
    },
    GitAdd = {
      text = { '│', '│' },
      priority = 5,
    },
    GitDelete = {
      text = { '│', '│' },
      priority = 5,
    },
    GitChange = {
      text = { '│', '│' },
      priority = 5,
    },
  },
  excluded_buftypes = {
    -- "terminal",
  },
  excluded_filetypes = {
    "",
    "TelescopePrompt",
    "chatgpt",
    "cmp_docs",
    "cmp_menu",
    "incline",
    "neo-tree",
    "notify",
    "prompt",
    "floaterm",
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

local function get_gitsign_lines(bufnr, nb_lines)
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

local add_git_signs = function(bufnr)
  local nb_lines = vim.api.nvim_buf_line_count(bufnr)
  return get_gitsign_lines(bufnr, nb_lines)
end

require('scrollbar.handlers').register('git', add_git_signs)
