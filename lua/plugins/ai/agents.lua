local opencode_port = vim.env.INSIDE_DOCKER and '4097' or '4096'

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>lo', group = 'OpenCode', mode = { 'n', 'v' } },
        { '<leader>lc', group = 'Cursor', mode = { 'n', 'v' } },
        { '<leader>lg', group = 'Gemini', mode = { 'n', 'v' } },
        { '<leader>l', group = 'llm', mode = { 'n', 'v' } },
      },
    },
  },
  {
    dir = vim.fn.stdpath('config') .. '/local/agents',
    name = 'agents',
    event = { 'User LazyBufEnter' },
    opts = {
      cursor = {
        executable = 'agent',
        filetype = 'cursor-agent',
        display_name = 'Cursor',
        leader = '<leader>lc',
        split = 'right',
        focus = true,
        insert = false,
      },
      opencode = {
        executable = 'opencode attach http://localhost:' .. opencode_port,
        filetype = 'opencode',
        display_name = 'OpenCode',
        leader = '<leader>lo',
        split = 'right',
        focus = true,
        insert = false,
      },
      gemini = {
        executable = 'gemini',
        filetype = 'gemini',
        display_name = 'Gemini',
        leader = '<leader>lg',
        split = 'right',
        focus = true,
        insert = false,
      },
    },
  },
}
