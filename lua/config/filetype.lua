vim.filetype.add({
  filename = {
    ['.clangd'] = 'yaml',
    ['run.test'] = 'python',
    ['clearml.conf'] = 'hocon',
    ['.gitlab-ci.yml'] = 'yaml.gitlab',
    ['.gitlab-ci.yaml'] = 'yaml.gitlab',
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
    gersemirc = 'yaml',
  },
  pattern = {
    ['.*%.cpp.tpl'] = 'cpp.jinja',
    ['gitlab.*%.txt'] = 'markdown',
    ['github.*%.txt'] = 'markdown',
  },
})
