local debounce_timer = nil

--- Sets up debounced auto-completion trigger on text changes in insert mode
--- @param debounce_delay number Delay in milliseconds before triggering completion
local function setup_text_changed_debounce(debounce_delay)
  vim.api.nvim_create_autocmd('InsertCharPre', {
    group = vim.api.nvim_create_augroup('TextChangedDebounceGroup', { clear = true }),
    callback = function()
      if vim.v.char == ' ' then
        if debounce_timer then
          debounce_timer:stop()
        end
        return
      end

      -- Cancel any existing timer to debounce rapid text changes
      if debounce_timer then
        debounce_timer:stop()
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
end
return {
  'saghen/blink.cmp',
  dependencies = { 'onsails/lspkind.nvim' },
  opts = function(_, opts)
    setup_text_changed_debounce(300)
    opts = opts or {}
    opts.completion.menu.draw.treesitter = {}
    opts.sources.default = vim
      .iter(opts.sources.default or {})
      :filter(function(source) return not vim.tbl_contains({ 'buffer', 'snippets' }, source) end)
      :totable()
    return vim.tbl_deep_extend('force', opts, {
      keymap = {
        preset = vim.g.ai_cmp and 'super-tab' or 'enter',
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-l>'] = {},
        ['<C-h>'] = {},
      },
      completion = {
        documentation = { window = { border = vim.g.winborder } },
        menu = {
          auto_show = false,
          direction_priority = { 'n', 's' },
          border = vim.g.winborder,
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
    })
  end,
}
