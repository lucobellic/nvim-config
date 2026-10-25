# Native statuscolumn

The local plugin renders signs, line numbers, and folds without Heirline.
Configuration lives in `lua/plugins/ui/statuscolumn.lua`.

The renderer preserves separate sign and Git columns, prefers cursor tab signs,
and keeps sign backgrounds consistent with the cursor line. It hides the column
for `nofile` buffers and Zen mode. With `signcolumn=no`, it only shows numbers.

Run the checks from the configuration root:

```sh
nvim --clean --headless -l local/statuscolumn/tests/statuscolumn.lua
```
