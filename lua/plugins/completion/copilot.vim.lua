return {
  'github/copilot.vim',
  enabled = vim.g.suggestions == 'copilot',
  event = 'BufEnter',
  keys = {
    {
      '<c-l>',
      function() vim.fn['copilot#Next']() end,
      desc = 'Copilot next',
      mode = 'i',
    },
    {
      '<c-h>',
      function() vim.fn['copilot#Prev']() end,
      desc = 'Copilot prev',
      mode = 'i',
    },
    {
      '<a-l>',
      '<Plug>(copilot-accept-word)',
      desc = 'Copilot accept word',
      mode = 'i',
    },
  },
  init = function()
    vim.g.copilot_workspace_folders = { '~/.config/nvim' }
    vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
    vim.g.copilot_integration_id = 'vscode-chat'

    if vim.env.INSIDE_DOCKER then
      table.insert(vim.g.copilot_workspace_folders, '~/rapidash')
    end
  end,
  config = function()
    if vim.env.INSIDE_DOCKER then
      vim.cmd('Copilot disable')
    end
  end,
}
