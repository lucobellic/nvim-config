# Native statusline

Define your statusline in `lua/plugins/ui/statusline.lua`. The local plugin only
handles components, layout, highlights, caching, and redraws. Plugin integrations
and your palette belong in the configuration, not in the renderer.

```lua
return {
  dir = vim.fn.stdpath('config') .. '/local/statusline',
  name = 'statusline',
  lazy = false,
  opts = {
    highlight = 'MyStatusline',
    highlights = {
      MyStatusline = { fg = '#70809b' },
      MyStatuslineAccent = { fg = '#AAD94C' },
    },
    left = {
      { provider = '%f %m%r', format = true, padding = { left = 1 } },
    },
    center = {
      { provider = '%y', format = true, hl = 'MyStatuslineAccent' },
    },
    right = {
      { provider = '%l:%c %p%%', format = true, padding = { right = 1 } },
    },
  },
}
```

## Components

Each position is an ordered list of component tables.

| Field | Meaning |
| --- | --- |
| `provider` | Text or a function returning text. Required. |
| `condition` | Optional function controlling visibility. |
| `hl` | Highlight group name or a function returning one. |
| `padding` | Optional `{ left = 1, right = 1 }` spacing. |
| `format` | Interpret native statusline syntax. Defaults to `false`. |
| `update` | Event list enabling provider caching and redraws. |

Literal text is escaped automatically, including `%`. Use `format = true` for
native fields such as `%f`, `%m`, and `%l`, or plugin output containing native
highlight markers and click regions. Empty output hides its padding too.

Every callback receives a context with `winid`, `bufnr`, `width` in display cells,
`active`, and the full Neovim `mode`. Use those handles instead of assuming that
the current window is being drawn. Conditions and highlight callbacks run on
every render, even when provider output is cached.

```lua
{
  condition = function(context)
    return vim.b[context.bufnr].gitsigns_status_dict ~= nil
  end,
  provider = function(context)
    return vim.b[context.bufnr].gitsigns_status_dict.head
  end,
  hl = 'MyStatuslineAccent',
  padding = { left = 1, right = 1 },
  update = { { event = 'User', pattern = 'GitSignsUpdate' } },
}
```

## Updates and caching

Without `update`, a function provider runs once per render. With `update`, output
is cached per window until a listed event fires. A different buffer, width,
active state, or mode also invalidates that window's entry. Closed windows are
removed from the cache. List all events relevant to your provider's data,
including cursor or text changes if the provider depends on them.

Events may be names or tables with `event` and optional `pattern`. Both fields
also accept lists. For example:

```lua
update = {
  'LspAttach',
  'LspDetach',
  { event = 'User', pattern = { 'LspProgressStatusUpdated', 'LazyLoad' } },
}
```

Events invalidate only their subscribed components. Redraw requests are
coalesced into one scheduled redraw. Calling `setup()` again replaces all
components and subscriptions. Static text and padding are compiled at setup.
For events that should only redraw dynamic providers, use the top level
`update` option. It accepts the same event syntax without enabling caching.

## Highlights and layout

`highlight` sets the base group for components and spacing. `highlights` defines
named groups using native `nvim_set_hl()` tables, or functions returning those
tables. Groups are restored on `ColorScheme`. `highlight_update` accepts the same
event syntax as `update` and refreshes dynamic definitions only. Unchanged
definitions are not rewritten. Highlights are never created during rendering.

Each component restores the base group after its output. For mixed highlights
inside a single `format = true` component, use native markers or
`require('statusline').highlight(format, group, restore_group)`. The helper wraps
a native format, not literal text. Use `escape(text)` first when needed.

The center is positioned against the full statusline width. Odd cell differences
favor the left by half a cell. If exact centering would overlap either side, the
center is hidden and native left/right alignment and truncation take over.
The renderer respects `laststatus=3` and window statuslines. Components must not
contain top level `%=` or `%!` expressions. Close click regions within the
component that opens them.

Native expressions may run during width measurement and final drawing. Keep
them cheap and free of side effects. An empty center skips width measurements.
There are no polling timers or persistent width caches in the plugin.
Custom integrations may request `require('statusline').redraw()` outside rendering.

## Existing configuration

Your configuration preserves the mode icon, Git, Lazy updates, debugger, macro
recording, centered layout indicators, tasks, LSP progress, CodeCompanion, search
count, separators, clock, and mode colors. Disabled components remain disabled.
Optional plugins are read only after loading. Search counts reuse native cached
results. Task summaries use event based caching. The CodeCompanion timer runs
only during active requests and is managed by the configuration.

## Checks

Run from the Neovim configuration root:

```sh
nvim --clean --headless -l local/statusline/tests/statusline.lua
nvim --clean --headless -l local/statusline/tests/statusline-config.lua
nvim --clean --headless -l local/statusline/tests/benchmark.lua
```

The benchmark reports average and p95 times, task list calls, and highlight
writes. It includes a search in 100,000 lines and 2,000 synthetic tasks. Results
depend on the machine and exclude live plugin costs and actual UI drawing.
