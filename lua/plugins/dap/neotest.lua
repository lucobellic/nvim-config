return {
  adapters = {
    require('nvim-neotest/neotest-python')({
      dap = { justMyCode = false },
    }),
    require('nvim-neotest/neotest-plenary'),
  },
}
