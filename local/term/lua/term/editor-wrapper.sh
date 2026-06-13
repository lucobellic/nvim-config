#!/bin/sh
# Editor wrapper for terminal tools to open files in current Neovim instance
# This prevents nested Neovim when using tools like lazygit or yazi

if [ -z "$NVIM" ]; then
  # Fallback to regular nvim if not running inside our terminal
  exec nvim "$@"
fi

if [ "$#" -eq 0 ]; then
  # No files provided, nothing to do
  exit 0
fi

# For each file, open it and wait for it to close
for file in "$@"; do
  # Create a unique flag file for this edit session
  flag_file="/tmp/nvim-wait-$$-$(date +%s%N)"

  # Ensure flag file is removed on script exit/interrupt
  cleanup() {
    rm -f "$flag_file"
  }
  trap cleanup EXIT INT TERM

  touch "$flag_file" || exit 1

  # Escape the file path for use in vim command
  escaped_file=$(printf '%s' "$file" | sed "s/'/'''/g")

  # Escape the flag file path for Lua string
  escaped_flag=$(printf '%s' "$flag_file" | sed "s/'/'''/g")

  # Exit terminal mode, hide the terminal, switch to previous window, open file, and set up wait tracking
  # The Lua code sets up an autocmd that deletes the flag file when the buffer is explicitly deleted.
  # bufhidden is intentionally NOT set to 'wipe' so switching to another buffer does not trigger deletion.
  nvim --server "$NVIM" --remote-send "<C-\\><C-N>:lua require('term.core').hide()<CR>:wincmd p<CR>:edit $escaped_file<CR>:lua vim.api.nvim_create_autocmd({'BufDelete', 'BufWipeout'}, { buffer = vim.api.nvim_get_current_buf(), callback = function() os.remove('$escaped_flag') end, once = true })<CR>"

  if [ "$?" -ne 0 ]; then
    echo "term: failed to communicate with parent Neovim" >&2
    exit 1
  fi

  # Wait for the flag file to be deleted (meaning buffer was closed)
  # Add a safety timeout of 5 minutes (3000 * 0.1s) to avoid hanging forever
  max_wait=3000
  waited=0
  while [ -f "$flag_file" ]; do
    sleep 0.1
    waited=$((waited + 1))
    if [ "$waited" -ge "$max_wait" ]; then
      echo "term: timeout waiting for file to close in parent Neovim" >&2
      exit 1
    fi
  done
done
