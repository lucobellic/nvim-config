return {
  'folke/edgy.nvim',
  opts = {
    bottom = {
      {
        title = 'toggleterm',
        ft = 'toggleterm',
        filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        open = function()
          local buffers = vim.tbl_filter(function(buf)
            local bufname = vim.fn.bufname(buf.bufnr)
            return bufname:find('toggleterm') ~= nil and bufname:find('toggleterm.lua') == nil
          end, vim.fn.getbufinfo({ buflisted = 0, buftype = 'terminal' }))

          local toggleterm_open = #require('toggleterm.terminal').get_all(true) > 1
          local terminal_open = toggleterm_open or #buffers > 0

          -- Create a terminal if none exist, otherwise toggle all terminals
          if terminal_open then
            -- Toggle all terminal buffers with name containing 'toggleterm'
            vim.tbl_map(function(buf) vim.cmd('sbuffer ' .. buf.bufnr) end, buffers)
            if toggleterm_open then
              require('toggleterm').toggle_all()
            end
          else
            require('toggleterm').toggle()
          end
        end,
      },
      {
        title = 'toggleterm-tasks',
        ft = '',
        filter = function(buf)
          local is_term = vim.bo[buf].buftype == 'terminal'
          local is_toggleterm = vim.fn.bufname(buf):find('toggleterm')
          return is_term and is_toggleterm
        end,
        open = '',
      },
      {
        title = 'overseer',
        ft = 'OverseerList',
        open = 'OverseerToggle!',
        size = { width = 0.15 },
      },
    },
  },
}
