local single = vim.g.winborder == 'single'

return {
  'nvim-zh/colorful-winsep.nvim',
  cond = not vim.g.neovide_floating_shadow,
  init = function()
    local augroup = vim.api.nvim_create_augroup('ColorfulWinsepLazyLoad', { clear = true })
    vim.api.nvim_create_autocmd('WinEnter', {
      group = augroup,
      callback = function()
        if vim.fn.winnr('$') >= 2 then
          require('lazy').load({ plugins = { 'colorful-winsep.nvim' } })
          vim.api.nvim_clear_autocmds({ group = augroup })
        end
      end,
    })
  end,
  opts = {
    animate = { enabled = false },
    border = single and { '─', '│', '┌', '┐', '└', '┘' } or { '─', '│', '╭', '╮', '╰', '╯' },
    highlight = '#127080',
    no_exec_files = {
      'packer',
      'TelescopePrompt',
      'mason',
      'NvimTree',
    },
    indicator_for_2wins = {
      position = 'center',
      symbols = {
        start_left = single and '┌' or '╭',
        end_left = single and '└' or '╰',
        start_down = single and '└' or '╰',
        end_down = single and '┘' or '╯',
        start_up = single and '┌' or '╭',
        end_up = single and '┐' or '╮',
        start_right = vim.g.winborder and '┐' or '╮',
        end_right = vim.g.winborder and '┘' or '╯',
      },
    },
    zindex = 20,
  },
}
