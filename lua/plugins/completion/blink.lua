local debounce_timer = nil
local function setup_text_changed_debounce(debounce_delay)
  vim.api.nvim_create_autocmd({ 'TextChangedI' }, {
    group = vim.api.nvim_create_augroup('TextChangedDebounceGroup', { clear = true }),
    callback = function()
      if debounce_timer then
        vim.fn.timer_stop(debounce_timer)
      end
      debounce_timer = vim.fn.timer_start(debounce_delay, function()
        if vim.api.nvim_get_mode()['mode'] == 'i' then
          require('blink.cmp').show()
        end
      end)
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
    return vim.tbl_deep_extend('force', opts, {
      keymap = {
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<C-j>'] = { 'select_next', 'fallback' },
      },
      sources = {
        default = { 'lsp', 'path' },
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
