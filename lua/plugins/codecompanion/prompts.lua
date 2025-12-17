return {
  'olimorris/codecompanion.nvim',
  opts = {
    opts = {
      language = 'english',
    },
    prompt_library = {
      markdown = {
        dirs = {
          vim.fn.stdpath('config') .. '/lua/plugins/codecompanion/prompts',
        },
      },
    },
  },
}
