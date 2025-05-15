local highlight = {
  'RainbowYellow',
  'RainbowLightGreen',
  'RainbowViolet',
  'RainbowBlue',
  'RainbowLightGreen',
  'RainbowCyan',
  'RainbowViolet',
}

return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  keys = {
    { '<leader>uI', '<cmd>IBLToggle<cr>', desc = 'Toggle indent blankline' },
  },
  opts = {
    indent = {
      char = '│',
      tab_char = '│',
      highlight = 'VertSplit',
    },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
      injected_languages = false,
      highlight = highlight,
      include = {
        node_type = {
          lua = { 'return_statement', 'table_constructor' },
          python = { '*' },
        },
        -- Make every node type valid. Note that this can lead to some weird behavior
        -- node_type = { ["*"] = { "*" } },
      },
    },
    exclude = {
      filetypes = {
        '',
        'TelescopePrompt',
        'TelescopeResults',
        'checkhealth',
        'git',
        'gitcommit',
        'help',
        'lspinfo',
        'man',
        'packer',
        'snacks_dashboard',
      },
    },
  },
  config = function(_, opts)
    local hooks = require('ibl.hooks')
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, 'RainbowRed', { link = 'TSRainbowRed' })
      vim.api.nvim_set_hl(0, 'RainbowYellow', { link = 'TSRainbowYellow' })
      vim.api.nvim_set_hl(0, 'RainbowBlue', { link = 'TSRainbowBlue' })
      vim.api.nvim_set_hl(0, 'RainbowOrange', { link = 'TSRainbowOrange' })
      vim.api.nvim_set_hl(0, 'RainbowGreen', { link = 'TSRainbowGreen' })
      vim.api.nvim_set_hl(0, 'RainbowLightGreen', { link = 'TSRainbowLightGreen' })
      vim.api.nvim_set_hl(0, 'RainbowViolet', { link = 'TSRainbowViolet' })
      vim.api.nvim_set_hl(0, 'RainbowCyan', { link = 'TSRainbowCyan' })
    end)

    require('ibl').setup(opts)
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
  end,
}
