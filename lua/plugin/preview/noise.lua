require("noice").setup {
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
    opts = {},
    format = {
      conceal = false -- This will hide the text in the cmdline that matches the pattern.
    }
  },
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
    },
    progress = {
      enabled = false
    },
    message = {
      enabled = true,
      view = "mini"
    },
    -- Prefer lspsaga for hover
    hover = {
      enabled = false
    },
    signature = {
      enabled = true
    }
  },

  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = { enabled = false },        -- use a classic bottom cmdline for search
    command_palette = { enabled = false },      -- position the cmdline and popupmenu together
    long_message_to_split = { enabled = true }, -- long messages will be sent to a split
    inc_rename = false,                         -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false,                     -- add a border to hover docs and signature help
  },
  views = {
    cmdline_popup = {
      position = {
        row = 3,
        col = "50%",
      },
      size = {
        width = "30%",
        height = "auto",
      },
      border = {
        style = "none",
        padding = { 1, 1 },
      },
      filter_options = {},
      win_options = {
        winhighlight = { Normal = "CursorLine", NormalFloat = "CursorLine", FloatBorder = "CursorLine" },
      },
    },
  },
  routes = {
    {
      filter = {
        any = {
          -- Hide Lspsaga messages spam message with outline open
          -- ex:   Info  4:47:18 PM notify.info [Lspsaga] Server of this buffer not support textDocument/documentSymbol
          { event = "notify",   kind = { "info" },          find = "[Lspsaga]" },
          { event = "notify",   kind = { "error" },         find = "[Neo-tree ERROR]" },
          -- Hide treesitter error due to experimental nvim-cmp ghost text completion
          { event = "msg_show", kind = { "lua_error", "" }, find = "query: invalid node" },
          -- Hide issues with autcommands "*" and matchup
          -- ex:   Error  5:05:55 PM msg_show.lua_error Error detected while processing CursorMoved Autocommands for "*"..
          { event = "msg_show", kind = { "lua_error" },     find = "matchup" },
          -- Hide issues with neovim-tree-parser while editing
          -- ex: col value outside range
          { event = "msg_show", kind = { "lua_error" },     find = "nvim-semantic-tokens" },
          { event = "lsp",      kind = { "" },              find = "pylsp" },
        },
      },
      opts = { skip = true },
    }
  },
  messages = {
    -- NOTE: If you enable messages, then the cmdline is enabled automatically.
    -- This is a current Neovim limitation.
    enabled = true,              -- enables the Noice messages UI
    view = "mini",               -- default view for messages
    view_error = "mini",         -- view for errors
    view_warn = "mini",          -- view for warnings
    view_history = "split",      -- view for :messages
    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
  },
  notify = {
    enabled = true,
    view = "mini"
  }
}
