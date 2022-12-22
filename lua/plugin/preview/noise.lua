require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
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
          { event = "msg_show", kind = { "lua_error", "" }, find = "query: invalid node" },
          -- Hide issue with autcommands "*" and matchup
          -- ex:   Error  5:05:55 PM msg_show.lua_error Error detected while processing CursorMoved Autocommands for "*"..
          { event = "msg_show", kind = { "lua_error" }, find = "matchup" },
        },
      },
      opts = { skip = true },
    }
  },
  messages = {
    -- NOTE: If you enable messages, then the cmdline is enabled automatically.
    -- This is a current Neovim limitation.
    enabled = true, -- enables the Noice messages UI
    view = "messages", -- default view for messages
    view_error = "messages", -- view for errors
    view_warn = "messages", -- view for warnings
    view_history = "messages", -- view for :messages
    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
  },
})
