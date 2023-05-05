-- Setup command line palette with wilder.nvim
local cmdline = {
  enabled = true,
  view = "cmdline_popup",
  opts = {},
  format = {
    conceal = false -- This will hide the text in the cmdline that matches the pattern.
  }
}

local cmdline_popup_view = {
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
    winhighlight = {
      Normal = "Normal",
      NormalFloat = "Normal",
      FloatBorder = "Normal"
    },
  },
}

local views = { cmdline_popup = cmdline_popup_view }


local lsp = {
  -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
  override = {
    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
    ["vim.lsp.util.stylize_markdown"] = true,
    ["cmp.entry.get_documentation"] = true,
  },
  progress = {
    enabled = true
  },
  message = {
    enabled = false,
    view = "mini"
  },
  -- Prefer lspsaga for hover
  hover = {
    enabled = false
  },
  signature = {
    enabled = true
  }
}

local filter_skip = {
  filter = {
    any = {
      -- Hide display messages but still show them in :messages
      { event = "msg_show", kind = { "", "echo", "echomsg", "search_count" }, find = "written" },
      { event = "msg_show", kind = "wmsg",                                    find = "BOTTOM" },
      { event = "msg_show", kind = "emsg",                                    find = "Neo" },
      { event = "msg_show", kind = "emsg",                                    find = "Pattern not found" },
      -- Hide spamming pylsp messages
      { find = "pylsp" }
    }
  },
  opts = { stop = true, skip = true },
}

local spinners = require('noice.util.spinners').spinners

-- Custom spinners
-- add programming font progress bar and spinner
-- such as fira code https://github.com/tonsky/FiraCode#whats-in-the-box
spinners.font_progress_bar = {
  frames = {
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  },
  interval = 100,
}

spinners.font_spinner = {
  frames = { "", "", "", "", "", "" },
  interval = 100,
}

require("noice").setup {
  cmdline = cmdline,
  lsp = lsp,

  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = { enabled = false },        -- use a classic bottom cmdline for search
    command_palette = { enabled = false },      -- position the cmdline and popupmenu together
    long_message_to_split = { enabled = true }, -- long messages will be sent to a split
    inc_rename = false,                         -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = true,                      -- add a border to hover docs and signature help
  },
  views = views,
  routes = { filter_skip },
  messages = {
    enabled = true,            -- enables the Noice messages UI
    view = "mini",             -- default view for messages
    view_error = "mini",       -- view for errors
    view_warn = "mini",        -- view for warnings
    view_history = "messages", -- view for :messages
    view_search = false,       -- view for search count messages. Set to `false` to disable
  },
  notify = {
    enabled = false,
    view = "mini"
  },
  format = {
    spinner = {
      name = "font_progress_bar",
    }
  }
}
