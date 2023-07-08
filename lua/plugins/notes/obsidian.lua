return {
  "epwalsh/obsidian.nvim",
  event = 'VeryLazy',
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    dir = "~/vault/work", -- no need to call 'vim.fn.expand' here
    notes_subdir = "notes",
    daily_notes = {
      folder = "dailies",
    },
    completion = {
      nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
    },
    disable_frontmatter = true,


    -- Optional, set to true if you use the Obsidian Advanced URI plugin.
    -- https://github.com/Vinzent03/obsidian-advanced-uri
    use_advanced_uri = true,

    -- Optional, set to true to force ':ObsidianOpen' to bring the app to the foreground.
    open_app_foreground = true,
    finder = "telescope.nvim",
  },
  keys = {
    { '<leader>oo', ':ObsidianOpen<cr>',        desc = 'Obsidian Open' },
    { '<leader>of', ':ObsidianQuickSwitch<cr>', desc = 'Obsidian Find Files' },
    { '<leader>os', ':ObsidianSearch<cr>',      desc = 'Obsidian Find Files' },
    { '<leader>ot', ':ObsidianToday<cr>',       desc = 'Obsidian Today' },
    { '<leader>oy', ':ObsidianYesterday<cr>',   desc = 'Obsidian Yesterday' },
  },
  config = function(_, opts)
    require("obsidian").setup(opts)

    -- Optional, override the 'gf' keymap to utilize Obsidian's search functionality.
    -- see also: 'follow_url_func' config option above.
    -- TODO: Set this keymap only with ob
    -- vim.keymap.set("n", "gf", function()
    --   if require("obsidian").util.cursor_on_markdown_link() then
    --     return "<cmd>ObsidianFollowLink<CR>"
    --   else
    --     return "gf"
    --   end
    -- end, { noremap = false, expr = true })
  end,
}