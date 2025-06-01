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

return {
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
      :filter(function(source) return not vim.tbl_contains({ 'buffer', 'snippets' }, source) end)
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
      preset = 'super-tab',
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<C-l>'] = {},
      ['<C-h>'] = {},
      ['<left>'] = { 'fallback' },
      ['<right>'] = { 'fallback' },
    }
    return opts
  end,
}
