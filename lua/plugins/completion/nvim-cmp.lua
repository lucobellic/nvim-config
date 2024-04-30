local function escape_lua_pattern(s)
  return s:gsub('.', {
    ['^'] = '%^',
    ['$'] = '%$',
    ['('] = '%(',
    [')'] = '%)',
    ['%'] = '%%',
    ['.'] = '%.',
    ['['] = '%[',
    [']'] = '%]',
    ['*'] = '%*',
    ['+'] = '%+',
    ['-'] = '%-',
    ['?'] = '%?',
    ['\0'] = '%z',
  })
end

-- Setup nvim-cmp.
local cmp = require('cmp')

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
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<cr>'] = safely_select,

  ['<Tab>'] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Insert,
    select = true,
  }),
  ['<S-Tab>'] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Insert,
    select = true,
  }),
  ['<C-l>'] = cmp.mapping(function(fallback)
    if cmp.visible() then
      local active_entry = cmp.get_active_entry() or cmp.get_entries()[1]
      if active_entry then
        local current_line = vim.fn.trim(vim.api.nvim_get_current_line(), ' ', 1)
        local suggestion = active_entry.cache.entries.get_word ---@type string
        local next_word = suggestion:gsub(escape_lua_pattern(current_line), ''):match('^%s*%S+%s?')
        vim.api.nvim_put({ next_word }, '', true, true)
      else
        cmp.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        })
      end
    else
      fallback()
    end
  end, { 'i', 'c' }),
}

return {
  'hrsh7th/nvim-cmp',
  event = { 'InsertEnter' },
  dependencies = {
    {
      'onsails/lspkind.nvim',
      config = function()
        require('lspkind').init({
          symbol_map = {
            Copilot = '',
          },
        })
      end,
    },
  },
  opts = {
    experimental = {
      native_menu = false,
      ghost_text = { hl_group = 'Comment' },
    },
    view = {
      entries = {
        follow_cursor = true,
      },
    },
    window = {
      completion = {
        border = vim.g.border,
        winhighlight = 'CursorLine:PmenuSel,Search:None',
        scrolloff = 0,
        col_offset = -3,
        side_padding = 1,
        scrollbar = true,
      },
      documentation = {
        border = vim.g.border,
        winhighlight = 'CursorLine:PmenuSel,Search:None',
      },
    },

    mapping = cmp.mapping.preset.insert(tab_confirm_mapping),
    -- vim.tbl_extend('force', opts.sources, {
    sources = {
      { name = 'copilot', group_index = 2 },
      { name = 'nvim_lsp', group_index = 2 },
      { name = 'luasnip', group_index = 2 },
      { name = 'buffer', group_index = 2 },
      { name = 'path', group_index = 2 },
      { name = 'nvim_lsp_signature_help', group_index = 3 },
    },
    formatting = {
      format = function(entry, item)
        item.menu = ''
        return require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 })(entry, item)
      end,
    },
  },
}
