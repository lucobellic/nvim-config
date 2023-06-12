return {
  { 'nvim-lua/popup.nvim', event = 'VeryLazy' },
  {
    'nvim-lua/plenary.nvim',
    config = function()
      require('plenary.filetype').add_file('filetype')
    end
  },
  { 'kkharji/sqlite.lua',  event = 'VeryLazy' },

  -- Other
  { 'moll/vim-bbye',       event = 'VeryLazy' },     -- Close buffer and window
  { 'xolox/vim-misc',      event = 'VeryLazy' },
  { 'honza/vim-snippets',  event = 'VeryLazy' },
  -- Visualize Markdown as mindmaps
  {
    "Zeioth/markmap.nvim",
    build = "yarn global add markmap-cli",
    cmd = { "MarkmapOpen", "MarkmapSave", "MarkmapWatch", "MarkmapWatchStop" },
    opts = {
      html_output = "/tmp/markmap.html", -- (default) Setting a empty string "" here means: [Current buffer path].html
      hide_toolbar = false,              -- (default)
      grace_period = 3600000             -- (default) Stops markmap watch after 60 minutes. Set it to 0 to disable the grace_period.
    },
    config = function(_, opts) require("markmap").setup(opts) end
  },
}
