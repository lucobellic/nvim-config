local function suggestion_key_fallback(key, action)
  local copilot_suggestion = require('copilot.suggestion')
  if copilot_suggestion.is_visible() then
    copilot_suggestion[action]()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'n', false)
  end
end

-- Enable Copilot keys only if nvim-cmp is not enabled
local get_keys = function()
  return not vim.g.ai_cmp
      and {
        {
          '<Tab>',
          function() suggestion_key_fallback('<Tab>', 'accept') end,
          desc = 'Copilot accept',
          mode = 'i',
        },
        {
          '<C-l>',
          function() suggestion_key_fallback('<C-l>', 'next') end,
          desc = 'Copilot next',
          mode = 'i',
        },
        {
          '<C-h>',
          function() suggestion_key_fallback('<C-h>', 'prev') end,
          desc = 'Copilot next',
          mode = 'i',
        },
      }
    or {}
end

return {
  'zbirenbaum/copilot.lua',
  enabled = vim.g.suggestions == 'copilot',
  keys = get_keys(),
  opts = {
    suggestion = {
      enabled = not vim.g.ai_cmp,
      auto_trigger = true,
      hide_during_completion = false,
      keymap = {
        accept = false,
        next = false,
        prev = false,
      },
    },
    filetypes = {
      markdown = true,
      gitcommit = true,
      gitrebase = true,
      hgcommit = true,
      svn = true,
    },
    server_opts_overrides = {
      settings = {
        advanced = {
          inlineSuggestCount = 3,
        },
      },
    },
  },
  config = function(_, opts)
    require('copilot').setup(opts)
    vim.cmd('Copilot disable')
  end,
}
