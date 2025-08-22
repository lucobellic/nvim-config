if vim.env.PROF then
  local snacks = vim.fn.stdpath('data') .. '/lazy/snacks.nvim'
  vim.opt.rtp:append(snacks)
  ---@diagnostic disable-next-line: missing-fields
  require('snacks.profiler').startup({
    startup = {
      event = 'VeryLazy',
    },
    pick = { picker = 'snacks' },
  })
end
