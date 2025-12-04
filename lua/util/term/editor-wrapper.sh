#!/bin/sh
# Editor wrapper for terminal tools to open files in current Neovim instance
# This prevents nested Neovim when using tools like lazygit or yazi

if [ -z "$NVIM" ]; then
  # Fallback to regular nvim if not running inside our terminal
  exec nvim "$@"
fi

# For each file, open it and wait for it to close
for file in "$@"; do
  # Create a unique flag file for this edit session
  flag_file="/tmp/nvim-wait-$$-$(date +%s%N)"
  touch "$flag_file"
  
  # Escape the file path for use in vim command
  escaped_file=$(printf '%s' "$file" | sed "s/'/'''/g")
  
  # Escape the flag file path for Lua string
  escaped_flag=$(printf '%s' "$flag_file" | sed "s/'/'''/g")
  
  # Exit terminal mode, hide the terminal, switch to previous window, open file, and set up wait tracking
  # The Lua code sets up an autocmd that deletes the flag file when the buffer is closed
  nvim --server "$NVIM" --remote-send "<C-\\><C-N>:lua require('util.term.core').hide()<CR>:wincmd p<CR>:edit $escaped_file<CR>:lua vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = 0 }); vim.api.nvim_create_autocmd({'BufDelete', 'BufWipeout'}, { buffer = 0, callback = function() os.remove('$escaped_flag') end, once = true })<CR>"
  
  # Wait for the flag file to be deleted (meaning buffer was closed)
  while [ -f "$flag_file" ]; do
    sleep 0.1
  done
done
