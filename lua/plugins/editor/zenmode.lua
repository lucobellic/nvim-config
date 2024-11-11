local current_buffer = nil
local current_filetype = nil

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>z', group = '+zen' },
      },
    },
  },
  {
    'folke/zen-mode.nvim',
    cmd = { 'ZenMode' },
    keys = {
      { '<leader>zz', '<cmd>ZenMode<cr>', desc = 'ZenMode' },
      { '<C-z>', '<cmd>ZenMode<cr>', desc = 'ZenMode' },
    },
    opts = {
      window = {
        backdrop = 1, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        -- height and width can be:
        -- * an absolute number of cells when > 1
        -- * a percentage of the width / height of the editor when <= 1
        width = 0.6, -- width of the Zen window
        height = 0.9, -- height of the Zen window
        zindex = 0, -- above all other window
        -- by default, no options are changed for the Zen window
        -- uncomment any of the options below, or add other vim.wo options you want to apply
        options = {
          signcolumn = 'no', -- disable signcolumn
          number = false, -- disable number column
          relativenumber = false, -- disable relative numbers
          cursorline = false, -- disable cursorline
          cursorcolumn = false, -- disable cursor column
          foldcolumn = '0', -- disable fold column
          list = false, -- disable whitespace characters
        },
      },
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = true,
          ruler = false, -- disables the ruler text in the cmd line area
          showcmd = false, -- disables the command in the last line of the screen
          laststatus = 0, -- turn off the statusline in zen mode
        },
        incline = { enabled = false }, -- disables the incline markers
        gitsigns = { enabled = false }, -- disables git signs
        tmux = { enabled = false }, -- disables the tmux statusline
        twilight = { enabled = false }, -- disables the twilight plugin
        -- this will change the font size on kitty when in zen mode
        -- to make this work, you need to set the following kitty options:
        -- - allow_remote_control socket-only
        -- - listen_on unix:/tmp/kitty
        kitty = {
          enabled = false,
          font = '+4', -- font size increment
        },
      },
      -- callback where you can add custom code when the Zen window opens
      on_open = function(win)
        current_buffer = vim.api.nvim_win_get_buf(win)
        current_filetype = vim.api.nvim_get_option_value('filetype', { buf = current_buffer })
        -- Change codecompanion to markdown to work with zen-mode
        if current_filetype == 'codecompanion' then
          vim.api.nvim_set_option_value('filetype', 'markdown', { buf = current_buffer })
        elseif current_filetype == 'toggleterm' then
          vim.api.nvim_set_option_value('filetype', 'terminal', { buf = current_buffer })
        end
      end,
      -- callback where you can add custom code when the Zen window closes
      on_close = function()
        -- Restore filetype if changed
        if current_buffer and current_filetype then
          vim.api.nvim_set_option_value('filetype', current_filetype, { buf = current_buffer })
          current_buffer = nil
          current_filetype = nil
        end
      end,
    },
  },
}
