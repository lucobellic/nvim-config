local blink_copilot = {
  'saghen/blink.cmp',
  optional = true,
  dependencies = { 'fang2hou/blink-copilot' },
  opts = {
    sources = {
      default = { 'copilot' },
      providers = {
        copilot = {
          name = 'copilot',
          module = 'blink-copilot',
          score_offset = 100,
          async = true,
        },
      },
    },
  },
}

local blink = {
  {
    'saghen/blink.cmp',
    dependencies = { 'onsails/lspkind.nvim' },
    version = '1.*',
    opts = function(_, opts)
      opts = opts or {}
      opts.sources = opts.sources or {}
      opts.sources.default = vim
        .iter(opts.sources.default or { 'lsp', 'path' })
        :filter(function(source) return not vim.tbl_contains({ 'snippets' }, source) end)
        :totable()

      ---@type blink.cmp.Config
      local config = {
        enabled = function() return not vim.tbl_contains({ 'snacks_input' }, vim.bo.filetype) end,
        cmdline = {
          enabled = true,
          completion = {
            list = { selection = { preselect = false } },
            menu = { auto_show = true },
          },
          keymap = {
            ['<tab>'] = false,
            ['<c-j>'] = { 'select_next', 'fallback' },
            ['<down>'] = { 'select_next', 'fallback' },
            ['<c-k>'] = { 'select_prev', 'fallback' },
            ['<up>'] = { 'select_prev', 'fallback' },
          },
        },
        completion = {
          list = { selection = { preselect = true, auto_insert = true } },
          documentation = { auto_show = false, window = { border = vim.g.winborder } },
          ghost_text = { enabled = function() return vim.g.ai_cmp or vim.g.suggestions == false end },
          menu = {
            auto_show = true,
            auto_show_delay_ms = 300,
            direction_priority = { 'n', 's' },
            border = vim.g.winborder,
            min_width = 35,
            draw = {
              components = {
                kind_icon = {
                  text = function(ctx)
                    -- For Path source, use devicons based on file type otherwise use lspkind
                    local icon = vim.tbl_contains({ 'Path' }, ctx.source_name)
                        and (require('nvim-web-devicons').get_icon(ctx.label) or ctx.kind_icon)
                      or require('lspkind').symbolic(ctx.kind)
                    return ' ' .. icon .. ' '
                  end,
                },
              },
              columns = {
                { 'kind_icon' },
                { 'label', 'label_description', gap = 1 },
              },
            },
          },
        },
      }
      opts = vim.tbl_deep_extend('force', opts, config)

      opts.completion.menu.draw.treesitter = {}
      opts.keymap = {
        preset = vim.g.cmp_mode,
        ['<tab>'] = { 'fallback' },
        ['<cr>'] = { 'accept', 'fallback' },
        ['<c-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<up>'] = { 'select_prev', 'fallback' },
        ['<down>'] = { 'select_next', 'fallback' },
        ['<c-k>'] = { 'select_prev', 'fallback' },
        ['<c-j>'] = { 'select_next', 'fallback' },
        ['<c-l>'] = {},
        ['<c-h>'] = {},
        ['<left>'] = { 'fallback' },
        ['<right>'] = { 'fallback' },
      }
      return opts
    end,
    config = function(_, opts)
      opts.sources.compat = nil
      require('blink.cmp').setup(opts)
    end,
  },
  {
    'rafamadriz/friendly-snippets',
    cond = false,
  },
}

if vim.g.ai_cmp then
  return vim.list_extend(blink, { blink_copilot })
else
  return blink
end
