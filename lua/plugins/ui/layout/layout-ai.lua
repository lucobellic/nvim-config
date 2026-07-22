local function not_floating(_, win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
end

local function ft_and(ft, fn)
  return function(buf, win) return vim.bo[buf].filetype == ft and fn(buf, win) end
end

return {
  'lucobellic/layout.nvim',
  opts = {
    right = {
      {
        name = 'codecompanion',
        picker = { icon = '', key = 'a' },
        views = {
          {
            name = 'codecompanion',
            filter = ft_and('codecompanion', not_floating),
            open = 'CodeCompanionChat toggle',
          },
        },
      },
      {
        name = 'opencode',
        picker = { icon = '', key = 'o' },
        views = {
          {
            name = 'opencode',
            filter = ft_and('opencode', not_floating),
            open = 'OpenCodeToggle',
          },
        },
      },
      {
        name = 'opencode2',
        picker = { icon = '"', key = '2' },
        views = {
          {
            name = 'opencode2',
            filter = ft_and('opencode2', not_floating),
            open = 'OpenCode2Toggle',
          },
        },
      },
      {
        name = 'cursor',
        picker = { icon = '', key = 'c' },
        views = {
          {
            name = 'cursor-agent',
            filter = ft_and('cursor-agent', not_floating),
            open = 'CursorToggle',
          },
        },
      },
      {
        name = 'codex',
        picker = { icon = '', key = 'x' },
        views = {
          {
            name = 'codex',
            filter = ft_and('codex', not_floating),
            open = 'CodexToggle',
          },
        },
      },
      {
        name = 'claude',
        picker = { icon = '', key = 'u' },
        views = {
          {
            name = 'claude',
            filter = ft_and('claude', not_floating),
            open = 'ClaudeToggle',
          },
        },
      },
      {
        name = 'gemini',
        picker = { icon = '󰊭', key = 'g' },
        views = {
          {
            name = 'gemini',
            filter = ft_and('gemini', not_floating),
            open = 'GeminiToggle',
          },
        },
      },
    },
  },
}
