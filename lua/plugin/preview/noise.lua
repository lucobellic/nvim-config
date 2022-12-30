require("noice").setup {
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
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
    bottom_search = { enabled = false }, -- use a classic bottom cmdline for search
    command_palette = { enabled = false }, -- position the cmdline and popupmenu together
    long_message_to_split = { enabled = true }, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
  views = {
    cmdline_popup = {
      border = {
        style = "none",
        padding = { 2, 3 },
      },
      filter_options = {},
      win_options = {
        winhighlight = { Normal = "CursorLine", NormalFloat = "CursorLine", FloatBorder = "CursorLine" },
      },
    },
    popupmenu = {
      enabled = true,
      backend = "nui",
      relative = "editor",
      position = {
        row = 8,
        col = "50%",
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = "none",
        padding = { 0, 1 },
      },
      win_options = {
        winhighlight = { Normal = "CursorLine", DiagnosticSignInfo = "CursorLine", FloatBorder = "CursorLine" },
      },
    },
  },
  cmdline = {
    enabled = false
  },
  routes = {
    {
      filter = {
        any = {
          -- Hide Lspsaga messages spam message with outline open
          -- ex:   Info  4:47:18 PM notify.info [Lspsaga] Server of this buffer not support textDocument/documentSymbol
          { event = "notify", kind = { "info" }, find = "[Lspsaga]" },
          -- Hide treesitter error due to experimental nvim-cmp ghost text completion
          { event = "msg_show", kind = { "lua_error", "" }, find =  "query: invalid node" },
          -- Hide issues with autcommands "*" and matchup
          -- ex:   Error  5:05:55 PM msg_show.lua_error Error detected while processing CursorMoved Autocommands for "*"..
          { event = "msg_show", kind = { "lua_error" }, find = "matchup" },
          -- Hide issues with neovim-tree-parser while editing
          -- ex: col value outside range
          { event = "msg_show", kind = { "lua_error" }, find = "nvim-semantic-tokens" },
        },
      },
      opts = { skip = true },
    }
  },
  messages = {
    -- NOTE: If you enable messages, then the cmdline is enabled automatically.
    -- This is a current Neovim limitation.
    enabled = true, -- enables the Noice messages UI
    view = "mini", -- default view for messages
    view_error = "mini", -- view for errors
    view_warn = "mini", -- view for warnings
    view_history = "mini", -- view for :messages
    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
  },
  commands = {
    history = {
      -- options for the message history that you get with `:Noice`
      view = "split",
      opts = { enter = true, format = "details" },
      filter = {
        any = {
          { event = "notify" },
          { error = true },
          { warning = true },
          { event = "msg_show", kind = { "" } },
          { event = "lsp", kind = "message" },
        },
      },
    },
  }
}
