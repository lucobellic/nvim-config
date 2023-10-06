return {
  'nvim-tree/nvim-web-devicons',
  opts = {
    -- TODO: Auto fill from filetype
    override_by_extension = {
      ['cuh'] = {
        color = "#70DF55",
        cterm_color = "2",
        icon = "",
        name = "CudaHeader"
      },
      ['cu'] = {
        color = "#70DF55",
        cterm_color = "2",
        icon = "",
        name = "Cuda"
      },
      ['ipp'] = {
        cterm_color = 74,
        color = '#519aba',
        icon = '',
        name = 'Ipp'
      },
      ['launch'] = {
        icon = '',
        color = '#ffbc03',
        cterm_color = 214,
        name = 'Launch'
      }
    }
  }
}
