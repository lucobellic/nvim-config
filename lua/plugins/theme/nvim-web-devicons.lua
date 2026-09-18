return {
  'nvim-tree/nvim-web-devicons',
  opts = {
    -- TODO: Auto fill from filetype
    override_by_extension = {
      ['ipp'] = {
        icon = '',
        color = '#519aba',
        cterm_color = 74,
        name = 'Ipp',
      },
      ['launch'] = {
        icon = '',
        color = '#ffbc03',
        cterm_color = 214,
        name = 'Launch',
      },
      ['qmd'] = {
        icon = '󰠮',
        color = '#ffbc03',
        cterm_color = 214,
        name = 'Quarto',
      },
      ['ezcan'] = {
        icon = '󰈀',
        color = '#6cb6eb',
        cterm_color = 74,
        name = 'Ezcan',
      },
      ['ezi'] = {
        icon = '󰘧',
        color = '#c2d94c',
        cterm_color = 148,
        name = 'Ezi',
      },
      ['msg'] = {
        icon = '󰍡',
        color = '#e6b450',
        cterm_color = 214,
        name = 'RosMsg',
      },
      ['srv'] = {
        icon = '󰍡',
        color = '#e6b450',
        cterm_color = 214,
        name = 'RosSrv',
      },
      ['action'] = {
        icon = '󰍡',
        color = '#e6b450',
        cterm_color = 214,
        name = 'RosAction',
      },
    },
    override_by_filename = {
      ['cmakelists.txt'] = {
        icon = '',
        color = '#6d8086',
        cterm_color = '66',
        name = 'CMakeLists',
      },
      ['Dockerfile'] = {
        icon = '󰡨',
        color = '#458ee6',
        name = 'Dockerfile',
      },
      ['Jenkinsfile'] = {
        icon = '',
        color = '#519aba',
        cterm_color = 74,
        name = 'Jenkinsfile',
      },
    },
  },
}
