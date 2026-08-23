local function not_floating(_, win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
end

local function ft_and(ft, fn)
  return function(buf, win) return vim.bo[buf].filetype == ft and fn(buf, win) end
end

return {
  'lucobellic/layout.nvim',
  opts = {
    right = {
      {
        name = 'search',
        views = {
          {
            name = 'grug-far',
            filter = ft_and('grug-far', not_floating),
          },
        },
      },
      {
        name = 'notes',
        views = {
          {
            name = 'notes',
            filter = function(buf, win)
              return vim.bo[buf].filetype == 'markdown'
                and not_floating(buf, win)
                and vim.api.nvim_buf_get_name(buf):find('/notes/') ~= nil
                and vim.g.layout_notes_disabled ~= true
            end,
          },
        },
      },
    },
  },
}
