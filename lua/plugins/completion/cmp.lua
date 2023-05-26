local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Setup nvim-cmp.
local lspkind = require('lspkind')
lspkind.init({
  symbol_map = {
    Copilot = "",
  },
})

local luasnip = require('luasnip')
local cmp = require('cmp')
local types = require('cmp.types')
local autocomplete = true

cmp.setup({
  experimental = {
    ghost_text = { hl_group = 'Comment' }
  },
  snippet = {
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  completion = {
    autocomplete = autocomplete and {
      types.cmp.TriggerEvent.TextChanged,
    }
  },
  window = {
    completion = {
      border = 'rounded',
      winhighlight = 'CursorLine:PmenuSel,Search:None',
      scrolloff = 0,
      col_offset = -3,
      side_padding = 1,
      scrollbar = true,
    },
    documentation = {
      border = 'rounded',
      winhighlight = 'CursorLine:PmenuSel,Search:None',
    },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = not autocomplete }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'copilot' }
  },
  formatting = {
    format = function(entry, vim_item)
      return lspkind.cmp_format({ mode = 'symbol_text', maxwidth = 50 })(entry, vim_item)
    end
  },
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})
