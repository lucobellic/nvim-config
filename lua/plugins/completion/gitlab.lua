return {
  'https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git',
  event = { 'BufReadPre', 'BufNewFile' },
  enabled = false,
  cond = function() return vim.g.suggestions == 'gitlab' end,
  opts = {
    gitlab_url = 'https://gitlab.easymile.com',
    statusline = { enabled = false },
    code_suggestions = {
      ghost_text = {
        enabled = true,
        toggle_enabled = false,
        accept_suggestion = false,
        clear_suggestions = false,
        stream = false,
      },
    },
    language_server = { workspace_settings = { telemetry = { enabled = false } } },
  },
  config = function(_, opts)
    require('gitlab').setup(opts)
    local ESC = vim.keycode('<Esc>')
    local GhostText = require('gitlab.ghost_text')
    vim.on_key(function(_, typed)
      if typed == ESC and GhostText.suggestion_shown then
        GhostText.clear_all_ghost_text()
      end
    end, nil)
  end,
}
