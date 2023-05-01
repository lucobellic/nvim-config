vim.filetype.add({
  filename = {
    ['.clangd'] = 'toml',
    ['run.test'] = 'python',
  },
  pattern = {
    ['.*%.ezi'] = 'ezi',
    ['.*%.launch'] = 'python',
  }
})
