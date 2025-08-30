-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
---@type LazySpec
return {
  'AstroNvim/astrocore',
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      autopairs = false,
      cmp = true,
      diagnostics = { virtual_text = false, virtual_lines = false },
      highlighturl = true,
      notifications = true,
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = {
        number = false,
        relativenumber = false,
      },
      g = { autoformat = false },
    },
    -- Mappings can be configured through AstroCore as well.
    mappings = {
      n = {
        --- Disable default keymap in favor of personal ones
        ['<Leader>c'] = false,
        ['<Leader>e'] = false,
        ['<Leader>fc'] = false,
        ['<Leader>fr'] = false,
        ['<Leader>gC'] = false,
        ['<Leader>gc'] = false,
        ['<Leader>h'] = false,
        ['<Leader>n'] = false,
        ['<Leader>o'] = false,
        ['<Leader>q'] = false,
        ['<Leader>uC'] = false,
        ['<Leader>ud'] = false,
        ['<Leader>gT'] = false,
        ['<Leader>gt'] = false,
        ['<F7>'] = false,
        ['<Leader>w'] = { '<c-w>', remap = true },
        ['<c-left>'] = false,
        ['<c-right>'] = false,
        ['<c-up>'] = false,
        ['<c-down>'] = false,
        ['c'] = { '<cmd>lua vim.g.change = true<cr>c', noremap = true, desc = 'Change' },
      },
      v = {
        ['c'] = { '<cmd>lua vim.g.change = true<cr>c', noremap = true, desc = 'Change' },
      },
    },
  },
}
