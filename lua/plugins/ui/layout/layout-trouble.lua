local function not_floating(_, win)
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == ''
end

local function ft_and(ft, fn)
  return function(buf, win) return vim.bo[buf].filetype == ft and fn(buf, win) end
end

local function trouble_mode(mode)
  return function(_, win)
    local t = vim.w[win].trouble
    if type(mode) == 'table' then
      return t and vim.list_contains(mode, t.mode) and not_floating(_, win)
    end
    return t and t.mode == mode and not_floating(_, win)
  end
end

return {
  'lucobellic/layout.nvim',
  opts = {
    bottom = {
      {
        name = 'diagnostics',
        picker = { icon = '', key = 'q' },
        views = {
          {
            name = 'qflist',
            filter = ft_and('trouble', trouble_mode({ 'qflist', 'quickfix' })),
            open = 'Trouble qflist toggle',
          },
          {
            name = 'diagnostics',
            filter = ft_and('trouble', trouble_mode('diagnostics')),
            open = 'Trouble diagnostics toggle filter.buf=0',
          },
          {
            name = 'loclist',
            filter = ft_and('trouble', trouble_mode('loclist')),
          },
          {
            name = 'todo',
            filter = ft_and('trouble', trouble_mode('todo')),
          },
          {
            name = 'quickfix',
            filter = 'qf',
          },
        },
      },
      {
        name = 'snacks',
        picker = { icon = '', key = 's' },
        views = {
          {
            name = 'snacks_list',
            filter = ft_and('trouble', trouble_mode('snacks')),
            open = 'Trouble snacks toggle',
          },
          {
            name = 'snacks_files',
            filter = ft_and('trouble', trouble_mode('snacks_files')),
            open = 'Trouble snacks_files toggle',
          },
          {
            name = 'telescope',
            filter = ft_and('trouble', trouble_mode('telescope')),
            open = 'Trouble telescope toggle',
          },
        },
      },
      {
        name = 'references',
        picker = { icon = '', key = 'r' },
        views = {
          {
            name = 'incoming',
            filter = ft_and('trouble', trouble_mode('incoming')),
            open = 'Trouble incoming toggle restore=true focus=false win.position=bottom',
          },
          {
            name = 'outgoing',
            filter = ft_and('trouble', trouble_mode('outgoing')),
            open = 'Trouble outgoing toggle restore=true focus=false win.position=bottom',
          },
          {
            name = 'in_out',
            filter = ft_and('trouble', trouble_mode('in_out')),
            open = 'Trouble in_out toggle restore=true focus=false win.position=bottom',
          },
        },
      },
      {
        name = 'lsp',
        picker = { icon = '', key = 'l' },
        views = {
          {
            name = 'definitions',
            filter = ft_and('trouble', trouble_mode('lsp_definitions')),
            open = 'Trouble lsp_definitions toggle restore=true',
          },
          {
            name = 'references',
            filter = ft_and('trouble', trouble_mode('lsp_references')),
            open = 'Trouble lsp_references toggle restore=true',
          },
          {
            name = 'lsp',
            filter = ft_and('trouble', trouble_mode('lsp')),
            open = 'Trouble lsp toggle restore=true focus=false win.position=bottom',
          },
        },
      },
    },
  },
}
