local prompt_model = vim.env.INSIDE_DOCKER and 'sol' or 'sonnet'
local spelling_model = vim.env.INSIDE_DOCKER and 'luna' or 'haiku'

return {
  dir = vim.fn.stdpath('config') .. '/local/inline-prompt',
  name = 'inline-prompt',
  main = 'inline-prompt',
  cond = not vim.g.vscode,
  keys = {
    {
      '<leader>ae',
      function() require('inline-prompt').prompt() end,
      mode = { 'n', 'x' },
      desc = 'Inline Prompt ' .. prompt_model,
    },
    { '<leader>aq', function() require('inline-prompt').cancel() end, desc = 'Inline Prompt Cancel' },
    {
      '<leader>as',
      function()
        require('inline-prompt').prompt(
          spelling_model,
          'Correct grammar as in the original language but keep the same meaning and formulation.'
        )
      end,
      mode = { 'n', 'x' },
      desc = 'Inline Prompt Grammar',
    },
    {
      '<leader>aS',
      function() require('inline-prompt').prompt(spelling_model, 'Correct grammar and reformulate.') end,
      mode = { 'n', 'x' },
      desc = 'Inline Prompt Spell',
    },
  },
  opts = { model = prompt_model },
}
