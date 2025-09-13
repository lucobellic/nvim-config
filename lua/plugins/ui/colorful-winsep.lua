local single = vim.g.winborder == 'single'
return {
  'nvim-zh/colorful-winsep.nvim',
  event = { 'WinEnter' },
  opts = {
    border = single and { '─', '│', '┌', '┐', '└', '┘' } or { '─', '│', '╭', '╮', '╰', '╯' },
    highlight = '#38526b',
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
