vim.filetype.add({
  filename = {
    ['.clangd'] = 'toml',
    ['run.test'] = 'python',
  },
  extension = {
    ezi = 'ezi',
    launch = 'python',
    cu = 'cpp',
    cuh = 'cpp',
    ansible = 'yaml.ansible',
    ['ansible.yaml'] = 'yaml.ansible',
    gitignore = 'gitignore',
    gitconfig = 'gitconfig',
    ['gitlab.txt'] = 'markdown',
    ['github.txt'] = 'markdown',
  },
  pattern = {
    ['gitlab.*%.txt'] = 'markdown',
    ['github.*%.txt'] = 'markdown',
  },
})
