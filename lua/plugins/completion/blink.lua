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

--- Fix https://github.com/saghen/blink.cmp/issues/2419 (timer race in queue_auto_show):
--- the completion menu can stay open after cursor moves away because a scheduled
--- timer callback runs after reset_auto_show() has already stopped the timer.
--- Overrides menu.queue_auto_show to check timer_key in the scheduled callback.
local function patch_blink_menu_race(menu)
  --- Creates the guarded timer callback that checks whether the menu should
  --- still open after the timer fires.
  ---@param auto table
  ---@param timer_key string
  local function make_show_callback(auto, timer_key)
    return vim.schedule_wrap(function()
      -- bail out if reset_auto_show() was called before this ran
      if auto.timer_key ~= timer_key then
        return
      end
      menu.open()
      menu.update_position()
    end)
  end

  --- Replacement for queue_auto_show with timer race guard.
  ---@param context blink.cmp.Context
  ---@param items blink.cmp.CompletionItem[]
  ---@diagnostic disable-next-line: duplicate-index
  menu.queue_auto_show = function(context, items)
    local auto = menu.auto_show
    if not auto.enabled(context, items) then
      return
    end

    local delay_ms = math.max(0, auto.delay_ms(context, items) - (vim.uv.now() - context.timestamp))

    if delay_ms == 0 then
      menu.open()
      menu.update_position()
      return
    end

    local timer_key = ('%d|%d|%d'):format(context.id, context.cursor[1], context.cursor[2])
    if auto.timer:is_active() and auto.timer_key == timer_key then
      return
    end

    auto.timer_key = timer_key
    auto.timer:start(delay_ms, 0, make_show_callback(auto, timer_key))
  end
end

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
            ['<up>'] = { function(cmp) return cmp.select_prev({ auto_insert = true }) end, 'fallback' },
            ['<down>'] = { function(cmp) return cmp.select_next({ auto_insert = true }) end, 'fallback' },
            ['<c-k>'] = { function(cmp) return cmp.select_prev({ auto_insert = true }) end, 'fallback' },
            ['<c-j>'] = { function(cmp) return cmp.select_next({ auto_insert = true }) end, 'fallback' },
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
      patch_blink_menu_race(require('blink.cmp.completion.windows.menu'))
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
