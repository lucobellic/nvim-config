local wk = require('which-key')

wk.register({
  ["<leader>"] = {
    ["p"] = { "Bottom Terminal" },
    ["m"] = { name = "+search" },
    ["t"] = { name = "+tabs" },
    ["e"] = { name = "+explorer" },
    ["b"] = { name = "+buffer" },
    ["h"] = { name = "+hunk" },
    ["a"] = { "action" },
    ["c"] = { name = "+coc" },
    ["ca"] = { name = "+action" },
    ["g"] = { name = "+git" },
    ["<leader>"] = { name = "+motion" },
    ["0"] = "which_key_ignore",
    ["1"] = "which_key_ignore",
    ["2"] = "which_key_ignore",
    ["3"] = "which_key_ignore",
    ["4"] = "which_key_ignore",
    ["5"] = "which_key_ignore",
    ["6"] = "which_key_ignore",
    ["7"] = "which_key_ignore",
    ["8"] = "which_key_ignore",
    ["9"] = "which_key_ignore"
  }
})
