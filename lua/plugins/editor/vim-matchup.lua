return {
  'andymass/vim-matchup',
  enabled = false,
  event = 'VeryLazy',
  opts = {},
  config = function()
    vim.g.matchup_matchparen_offscreen = {}
    -- disable highlighting in insert mode,
    vim.g.matchup_matchparen_nomode = 'i'
  end,
}
