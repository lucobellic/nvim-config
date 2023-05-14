local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This extension requires 'telescope.nvim'. (https://github.com/nvim-telescope/telescope.nvim)")
end

local telescope_asynctasks_picker = require("telescope._extensions.asynctasks.picker")

return telescope.register_extension({
  exports = {
    asynctasks = telescope_asynctasks_picker.asynctasks_picker,
  },
})
