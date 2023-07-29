vim.filetype.add({
  filename = {
    ['.clangd'] = 'toml',
    ['run.test'] = 'python',
  },
  pattern = {
    ['.*%.ezi'] = 'ezi',
    ['.*%.launch'] = 'python',
    ['.*%.cu'] = 'cpp',
    ['.*%.cuh'] = 'cpp',
    ['.*%.ansible'] = 'yaml.ansible',
    ['.*%.ansible%.yaml'] = 'yaml.ansible',
  }
})
