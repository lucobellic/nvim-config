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

local debounce_timer = nil
local function setup_text_changed_debounce(debounce_delay)
  vim.api.nvim_create_autocmd({ 'TextChangedI' }, {
    group = vim.api.nvim_create_augroup('TextChangedDebounceGroup', { clear = true }),
    callback = function()
      if debounce_timer then
        vim.fn.timer_stop(debounce_timer)
      end
      debounce_timer = vim.fn.timer_start(debounce_delay, function() require('cmp').complete({ reason = 'auto' }) end)
    end,
  })
end

return {
  'llllvvuu/nvim-cmp',
  branch = 'feat/above',
  -- 'hrsh7th/nvim-cmp',
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
        if
          cmp.visible() --[[ and cmp.get_active_entry() ]]
        then
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
      -- ['<Tab>'] = cmp.mapping.confirm({
      --   behavior = cmp.ConfirmBehavior.Insert,
      --   select = true,
      -- }),
      -- ['<S-Tab>'] = cmp.mapping.confirm({
      --   behavior = cmp.ConfirmBehavior.Insert,
      --   select = true,
      -- }),
      ['<Down>'] = { i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }) },
      ['<Up>'] = { i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }) },
      ['<C-k>'] = { i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }) },
      ['<C-j>'] = { i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }) },
      ['<C-g>'] = function()
        if cmp.visible_docs() then
          cmp.close_docs()
        else
          cmp.open_docs()
        end
      end,
      ['<C-x>'] = cmp.mapping.complete({ config = { sources = cmp.config.sources({ { name = 'cmp_ai' } }) } }),
    }
    opts.mapping = vim.tbl_deep_extend('force', opts.mapping, tab_confirm_mapping)

    opts.sources = opts.sources or {}
    opts.sources = insert_or_replace(opts.sources, { name = 'nvim_lsp_signature_help', group_index = 2 })
    opts.sources = insert_or_replace(opts.sources, { name = 'buffer', group_index = 1 })
    opts.sources = insert_or_replace(opts.sources, { name = 'path', group_index = 1 })
    opts.sources = insert_or_replace(opts.sources, { name = 'snippets', group_index = 1 })
    opts.sources = insert_or_replace(opts.sources, { name = 'nvim_lsp', group_index = 1 })

    if vim.g.suggestions == 'copilot' and vim.g.ai_cmp then
      opts.sources = insert_or_replace(opts.sources, { name = 'copilot', keyword_length = 0, group_index = 1 })
    end

    -- Enable ghost text if ai completion is integrated to cmp or if no ai suggestions is enabled
    opts.experimental.ghost_text = (vim.g.ai_cmp or vim.g.suggestions == false) and { hl_group = 'Comment' } or false

    setup_text_changed_debounce(500)

    return vim.tbl_deep_extend('force', opts, {
      completion = {
        autocomplete = false, -- Triggered on TextChangedDebounce
      },
      performance = {
        debounce = 300,
        throttle = 300,
      },
      matching = {
        disallow_fuzzy_matching = false,
        disallow_fullfuzzy_matching = false,
        disallow_partial_fuzzy_matching = false,
        disallow_partial_matching = false,
        disallow_prefix_unmatching = false,
        disallow_symbol_nonprefix_matching = true,
      },
      view = {
        entries = {
          name = 'custom',
          vertical_positioning = 'above',
          selection_order = 'near_cursor',
          follow_cursor = false,
        },
        docs = {
          auto_open = false,
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
      formatting = {
        fields = { 'kind', 'abbr' },
        format = function(entry, vim_item)
          local format = require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 })
          local kind = format(entry, vim_item)
          local strings = vim.split(kind.kind, '%s', { trimempty = true })
          kind.kind = ' ' .. (strings[1] or '') .. ' '
          -- kind.menu = '    (' .. (strings[2] or '') .. ')'
          return kind
        end,
      },
    })
  end,
}
