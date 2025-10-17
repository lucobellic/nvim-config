return {
  'snacks.nvim',
  opts = {
    image = {
      enabled = not vim.env.INSIDE_DOCKER,
      doc = {
        inline = false,
        float = true,
      },
    },
    styles = {
      snacks_image = {
        border = 'none',
        relative = 'cursor',
        col = 1,
        row = 1,
      },
    },
  },
}
