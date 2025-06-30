local debounce_timer = nil

--- Sets up debounced auto-completion trigger on text changes in insert mode
--- @param debounce_delay number Delay in milliseconds before triggering completion
local function setup_text_changed_debounce(debounce_delay)
  vim.api.nvim_create_autocmd('InsertCharPre', {
    group = vim.api.nvim_create_augroup('TextChangedDebounceGroup', { clear = true }),
    callback = function()
      -- Cancel any existing timer to debounce rapid text changes
      if debounce_timer then
        debounce_timer:stop()
      end

      if vim.v.char == ' ' then
        return
      end

      -- Set up a new timer to show completion after the specified delay
      debounce_timer = vim.defer_fn(function()
        -- Only show completion if we're still in insert mode
        if vim.api.nvim_get_mode().mode == 'i' then
          require('blink.cmp').show()
        end
      end, debounce_delay)
    end,
  })

  -- Stop the timer when leaving insert mode
  vim.api.nvim_create_autocmd('InsertLeave', {
    group = vim.api.nvim_create_augroup('StopDebounceTimerGroup', { clear = true }),
    callback = function()
      if debounce_timer then
        debounce_timer:stop()
      end
    end,
  })
end

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
  'saghen/blink.cmp',
  dependencies = { 'onsails/lspkind.nvim' },
  opts = function(_, opts)
    ---@type number | nil debounce time in milliseconds or nil to disable
    local debounce = nil

    if debounce then
      setup_text_changed_debounce(debounce)
    end

    opts = opts or {}
    opts.sources = opts.sources or {}
    opts.sources.default = vim
      .iter(opts.sources.default or { 'lsp', 'path' })
      :filter(function(source) return not vim.tbl_contains({ 'snippets', 'buffer' }, source) end)
      :totable()

    ---@type blink.cmp.Config
    local config = {
      cmdline = {
        enabled = true,
        completion = { menu = { auto_show = true } },
        keymap = {
          ['<Tab>'] = { 'show', 'accept' },
          ['<c-j>'] = { 'select_next', 'fallback' },
          ['<down>'] = { 'select_next', 'fallback' },
          ['<c-k>'] = { 'select_prev', 'fallback' },
          ['<up>'] = { 'select_prev', 'fallback' },
        },
      },
      completion = {
        list = { selection = { preselect = true, auto_insert = true } },
        documentation = { auto_show = false, window = { border = vim.g.winborder } },
        ghost_text = { enabled = vim.g.ai_cmp or vim.g.suggestions == false },
        menu = {
          auto_show = debounce == nil,
          direction_priority = { 'n', 's' },
          border = vim.g.winborder,
          min_width = 35,
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  -- For Path source, use devicon based on file type otherwise use lspkind
                  local icon = vim.tbl_contains({ 'Path' }, ctx.source_name)
                      and (require('nvim-web-devicons').get_icon(ctx.label) or ctx.kind_icon)
                    or require('lspkind').symbolic(ctx.kind, { mode = 'symbol' })
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
      ['<tab>'] = vim.g.cmp_mode ~= 'super-tab' and { 'fallback_to_mappings' } or { 'accept', 'fallback' },
      ['<cr>'] = vim.g.cmp_mode ~= 'enter' and { 'fallback_to_mappings' } or { 'accept', 'fallback' },
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
}

if vim.g.ai_cmp then
  return vim.list_extend({ blink }, { blink_copilot })
else
  return blink
end
