return {
  'nvim-tree/nvim-web-devicons',
  opts = {
    -- TODO: Auto fill from filetype
    override_by_extension = {
      ['cuh'] = {
        icon = '',
        color = '#70DF55',
        cterm_color = '2',
        name = 'CudaHeader',
      },
      ['cu'] = {
        icon = '',
        color = '#70DF55',
        cterm_color = '2',
        name = 'Cuda',
      },
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
        name = 'Jenkinsfile'
      }
    },
  },
}
