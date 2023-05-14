local M = {}

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

function M.asynctasks_picker()
  local opts = {}

  local function get_line_number(entry)
    local lines = vim.fn.readfile(entry.source)
    local lnum = 0
    local pattern = '^%[' .. entry.name:gsub('%-', '%%-')
    for i, line in ipairs(lines or {}) do
      if line:find(pattern) then
        lnum = i
        break
      end
    end
    return lnum
  end

  local function entry_maker(entry)
    return {
      value = entry,
      path = entry.source,
      display = entry.name,
      ordinal = entry.name,
      lnum = get_line_number(entry)
    }
  end

  local function attach_mappings(prompt_bufnr, map)
    actions.select_default:replace(function()
      actions.close(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      vim.api.nvim_call_function('asynctasks#start', { '', entry.value.name, '' })
    end)
    return true
  end

  pickers.new(opts, {
    prompt_title = "Search Tasks",
    results_title = "Tasks",
    finder = finders.new_table({
      results = vim.api.nvim_call_function('asynctasks#list', { '' }),
      entry_maker = entry_maker,
    }),
    previewer = require('telescope.config').values.grep_previewer(opts),
    sorter = require('telescope.sorters').get_generic_fuzzy_sorter(opts),
    attach_mappings = attach_mappings,
  }):find()
end

return M
