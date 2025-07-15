local M = {
  highlight_groups = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
  disabled = false,
  original = {},
}

function M.toggle()
  if not M.disabled then
    vim.iter(M.highlight_groups):each(function(group)
      M.original[group] = vim.api.nvim_get_hl(0, { name = group })
      vim.api.nvim_set_hl(0, group, { bg = 'NONE', fg = 'NONE' })
    end)
    M.disabled = true
    vim.notify('Diffview highlights disabled', vim.log.levels.INFO)
  else
    vim.iter(M.original):each(function(group, hl) vim.api.nvim_set_hl(0, group, hl) end)
    M.disabled = false
    vim.notify('Diffview highlights restored', vim.log.levels.INFO)
  end
end

function M.is_disabled() return M.disabled end

return M
