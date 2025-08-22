vim.lsp.config('nil_ls', {
  settings = {
    ['nil'] = {
      formatting = { command = 'nixfmt' },
      nix = {
        -- Whether to auto-eval flake inputs.
        -- The evaluation result is used to improve completion, but may cost
        -- lots of time and/or memory.
        flake = {
          autoEvalInputs = true,
        },
      },
    },
  },
})
