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

---@param sources table
---@param to_insert table { name: string }
---@return table sources
local function insert_or_replace(sources, to_insert)
  for i, source in ipairs(sources) do
    if source.name == to_insert.name then
      table.remove(sources, i)
      table.insert(sources, 1, to_insert)
      return sources
    end
  end

  table.insert(sources, 1, to_insert)
  return sources
end

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
  opts = function(_, opts)
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

    opts.sources = opts.sources or {}
    opts.sources = insert_or_replace(opts.sources, { name = 'nvim_lsp_signature_help', group_index = 2 })
    opts.sources = insert_or_replace(opts.sources, { name = 'buffer', group_index = 1 })
    opts.sources = insert_or_replace(opts.sources, { name = 'path', group_index = 1 })
    opts.sources = insert_or_replace(opts.sources, { name = 'snippets', group_index = 1 })
    opts.sources = insert_or_replace(opts.sources, { name = 'nvim_lsp', group_index = 1 })
    opts.sources = insert_or_replace(opts.sources, { name = 'copilot', group_index = 1 })

    return vim.tbl_deep_extend('force', opts, {
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
          border = vim.g.border.style,
          winhighlight = 'CursorLine:PmenuSel,Search:None',
          scrolloff = 0,
          col_offset = -3,
          side_padding = 1,
          scrollbar = true,
        },
        documentation = {
          border = vim.g.border.style,
          winhighlight = 'CursorLine:PmenuSel,Search:None',
        },
      },
      mapping = cmp.mapping.preset.insert(tab_confirm_mapping),
      formatting = {
        format = function(entry, item)
          item.menu = ''
          return require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 })(entry, item)
        end,
      },
    })
  end,
}
