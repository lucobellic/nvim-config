local cmd_output = vim.fn.systemlist('node --version')
local node_version = string.match(cmd_output[#cmd_output], "^v(%S+)") or ""
require('copilot.client').node_version = node_version

require("copilot").setup({
  filetypes = {
    yaml = false,
    markdown = true,
    help = false,
    gitcommit = true,
    gitrebase = true,
    hgcommit = true,
    svn = true,
    cvs = false,
    ["."] = false,
  },
})
