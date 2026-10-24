# Native statusline

Configure sections in `lua/plugins/ui/statusline.lua`. The renderer lives in
`local/statusline/lua/statusline/init.lua` and has no plugin dependencies.

The current configuration preserves the previous statusline:

- Left: mode icon, Git branch, Lazy updates, separator, debugger, macro recording.
- Center: bottom layout indicators when `vim.g.layout == 'layout'`.
- Right: Overseer tasks, LSP progress, CodeCompanion, search count, separator, clock.

Components live in `local/statusline/lua/statusline/components.lua`. Mode colors
and the original palette live in `local/statusline/lua/statusline/theme.lua`.
Events live in `local/statusline/lua/statusline/events.lua`.
Optional plugins are read only after loading.
Previously disabled Copilot, Sidekick, and system statistics remain disabled.

```lua
local statusline = require('statusline')

statusline.setup({
  left = ' %f %m%r',
  center = '%y',
  right = '%l:%c %p%% ',
})
```

Each section accepts a native statusline format or a function returning one.
Missing sections and empty strings are hidden. `setup()` replaces all sections.

```lua
statusline.setup({
  left = function(context)
    return context.active and ' %f %m%r' or ' %f'
  end,
  center = '%y',
  right = '%l:%c ',
})
```

Providers receive `winid`, `bufnr`, `width` in display cells, and `active`.
Use those handles rather than assuming the current window is being drawn.
Use `statusline.escape(text)` for literal text containing `%`.

Native fields such as `%f`, `%m`, `%l`, and `%c` remain Neovim's responsibility.
Use `%#Group#` and `%*` for highlights, or `statusline.highlight(format, group,
restore_group)` to wrap a native format. The optional restore group defaults to
the native statusline highlight. Escape literal text before wrapping it.
Set `highlight = 'Group'` in `setup()` for a base highlight, including spacing.
Each section resets its highlight before the next gap or section. Close native
click regions within their section.
Sections must not contain top level `%=` or `%!` expressions because the renderer
owns alignment and the outer expression.

The center is positioned against the full statusline width, not the space
between the sides. Odd cell differences favor the left by half a cell. If the
center cannot fit without overlapping a side, it is hidden. Neovim then handles
left and right alignment and truncation, starting at the left edge.

The renderer respects `laststatus`. With `laststatus=3` it uses the full editor
width. Otherwise it uses the target window width. It does not change that option.

Each provider runs once per render. Native expressions can run during both width
measurement and final drawing, so keep them cheap and free of side effects.
The core has no polling timers, redraw autocmds, or persistent width caches. When
the center is empty, rendering uses native alignment without measuring sections.
For data changed outside normal editor activity, request `:redrawstatus` from
the code that updates that data, not from a provider.

The configured integrations use targeted events for redraws and recreate
highlights on `ColorScheme`. The CodeCompanion spinner uses a timer only while
requests are active and closes it when they finish or Neovim exits. The clock
updates on normal redraws, as before, without a dedicated timer.

Run the focused checks from the Neovim configuration root:

```sh
nvim --clean --headless -l local/statusline/tests/statusline.lua
nvim --clean --headless -l local/statusline/tests/statusline-config.lua
```
