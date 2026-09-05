# undo-keep

Local, dependency-free undo preservation for Neovim 0.13. Loaded eagerly by
`lua/plugins/misc/undo-keep.lua`, replacing the Fundo plugin spec.

## Behavior

- **Changes while a file is open:** leaves `undoreload` unchanged. Neovim's
  default of `10000` limits reload undo based on each buffer's line count,
  not the combined size of open files. Large-file reloads can discard history.
- **Changes while a file is closed:** saves a content snapshot together with
  its undo tree. On reopening changed content, restores the previous tree and
  adds the external content as one new undo step. `u` returns to the previous
  content; further undo and branch navigation access the older history.
- **Neovim 0.13 filesystem detection:** uses the built-in watcher and reload
  behavior. No additional watcher, polling timer, `checktime` autocmd, or
  `FileChangedShell` handler. Your `autoread` setting and conflict handling are
  left alone. Explicit `:edit!` reloads follow the same native undo policy.
- **Normal persistent undo:** leaves `undofile` and native undo files intact.
  Never replaces a tree Neovim has already loaded.

Snapshots are saved after writes and when unmodified buffers unload (including
normal exit). Unsaved edits are not backed up by this plugin. Special buffers,
binary buffers, and buffers with undo persistence or undo disabled are skipped.
Damaged snapshots produce a warning and are validated in a scratch buffer
before touching the file buffer. Restoring history does not write to the file.

## Storage and limitations

Snapshots live in `stdpath('state')/undo-keep` (normally
`~/.local/state/nvim/undo-keep`). Each hashed absolute file path has one atomic
snapshot containing both the text and undo data. The directory uses `0700`
permissions and snapshots use `0600`.

- Snapshots contain **full file contents and historical text**, just like undo
  files. They are not encrypted or automatically expired. Disable `undofile`
  for sensitive files before editing them; doing so does not erase old caches.
- Snapshots duplicate the text/undo data on disk, with synchronous work on
  save/unload. `undoreload` limits native reload undo only; it is not a size
  limit for these persistent snapshots or for ordinary editing history.
- Multiple Neovim instances editing the same path use last-writer-wins caching;
  their undo trees are not merged. Renamed paths get separate snapshots.
- Recovery starts once this plugin has captured a snapshot. It does not import
  Fundo's backup format or recover previously lost history.
- Text changes are undoable; file permissions, encoding changes, and filesystem
  metadata are not tracked as separate undo operations.
- Plugin-managed editors that create and rewrite buffers through APIs instead
  of Neovim's normal file-read/reload path are unsupported. There is no general
  event that distinguishes their initialization edits from intentional edits;
  Neogit's commit editor is one such case.

Restart Neovim to activate the replacement. No Home Manager rebuild is needed.

## Tests

From `~/.config/nvim`, with `nvim` pointing to Neovim 0.13:

```sh
test_root=$(mktemp -d /tmp/opencode/undo-keep.XXXXXX)
XDG_STATE_HOME="$test_root/state" XDG_DATA_HOME="$test_root/data" \
  nvim --clean --headless -l local/undo-keep/tests/run.lua
stylua --check local/undo-keep lua/plugins/misc/undo-keep.lua
```

The tests use isolated storage and cover offline edits, separate-process
persistence, native filesystem detection with atomic file replacement,
`:checktime`, `:edit!`, large files, undo branches, unchanged files, corrupt
snapshots, disabled persistence, and preservation of unsaved local edits.
