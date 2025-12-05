return {
  'chomosuke/term-edit.nvim',
  event = 'TermOpen',
  opts = {
    prompt_end = '% ',
    feedkeys_delay = 10,
    use_up_down_arrows = function()
      local line = vim.fn.getline(vim.fn.line('.'))
      if line:find(']:', 1, true) or line:find('...:', 1, true) then
        return true
      end
      return false
    end,
  },
}
