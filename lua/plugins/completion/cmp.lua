local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
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

local safely_select = cmp.mapping({
  i = function(fallback)
    if cmp.visible() and cmp.get_active_entry() then
      cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
    else
      fallback()
    end
  end,
  s = cmp.mapping.confirm({ select = true }),
  c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
})

local tab_confirm_mapping = {
  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  ['<C-f>'] = cmp.mapping.scroll_docs(4),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<cr>'] = safely_select,

  ['<esc>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.abort()
      vim.api.nvim_input('<esc>')
    else
      fallback()
    end
  end, { 'i', 'c' }),

  ["<Tab>"] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Insert,
    select = true,
  }),
  ["<S-Tab>"] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Insert,
    select = true,
  }),
  ['<C-right>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
      local active_entry = cmp.get_active_entry() or cmp.get_entries()[1]
      if active_entry then
        local current_line = vim.fn.trim(vim.api.nvim_get_current_line(), ' ', 1)
        local suggestion = active_entry.cache.entries.get_word
        -- TODO: Find an alternative to gsub to handle special characters
        local next_word = suggestion:gsub('^' .. current_line, ''):match('^%s*%S+%s?')
        vim.api.nvim_put({ next_word }, '', true, true)
      else
        cmp.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true
        })
      end
    else
      fallback()
    end
  end, { 'i', 'c' }),
}

-- Use tab to select an item and esc to insert it
-- Escaping during navigation with up/down aborts the completion
local tab_selection_mapping = {
  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  ['<C-f>'] = cmp.mapping.scroll_docs(4),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<cr>'] = safely_select,

  ['<esc>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
      if cmp.confirm({ select = false }) then
        vim.api.nvim_input('<esc>')
      else
        fallback()
      end
    else
      fallback()
    end
  end, { 'i', 'c' }),

  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() and has_words_before() then
      cmp.select_next_item()
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    else
      fallback()
    end
  end, { "i", "s" }),

  ["<S-Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() and has_words_before() then
      cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end, { "i", "s" }),
}

cmp.setup({
  experimental = {
    native_menu = false,
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
  mapping = cmp.mapping.preset.insert(
  -- tab_selection_mapping
    tab_confirm_mapping
  ),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'copilot' },
    { name = "nvim_lsp_signature_help" },
    { name = "path" },
  },
  formatting = {
    format = function(entry, vim_item)
      return lspkind.cmp_format({ mode = 'symbol_text', maxwidth = 50 })(entry, vim_item)
    end
  },
})
