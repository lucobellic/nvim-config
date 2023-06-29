return {
  settings = {
    pylsp = {
      configurationSources = { 'flake8', 'pycodestyle' },
      plugins = {
        rope_completion = {
          enabled = true
        },
        flake8 = {
          enabled = true
        },
        pylint = {
          enabled = false
        },
        pyright = {
          enabled = false
        },
        pydocstyle = {
          enabled = false
        },
        pycodestyle = {
          maxLineLength = 100,
          enabled = true
        }
      }
    }
  }
}
