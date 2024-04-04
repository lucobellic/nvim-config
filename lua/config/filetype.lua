vim.filetype.add({
  filename = {
    ['.clangd'] = 'yaml',
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
    rviz = 'yaml',
  },
  pattern = {
    ['gitlab.*%.txt'] = 'markdown',
    ['github.*%.txt'] = 'markdown',
  },
})
