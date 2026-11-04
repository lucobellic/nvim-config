return {
  'xb-bx/editable-term.nvim',
  ft = { 'terminal', 'term' },
  opts = {
    promts = {
      ['^  '] = {},
    },
  },
  ---@param _ LazyPlugin
  ---@param opts EditableTermConfig
  config = function(_, opts)
    require('editable-term').setup(opts)

    -- Run after the plugin attaches so copying cannot interrupt terminal commands.
    vim.api.nvim_create_autocmd('TermOpen', {
      group = vim.api.nvim_create_augroup('EditableTermSafeYank', { clear = true }),
      ---@param event vim.api.keyset.create_autocmd.callback_args
      callback = function(event)
        if vim.bo[event.buf].filetype == 'opencode' then
          vim.api.nvim_clear_autocmds({
            group = 'editable-term-text-change' .. event.buf,
            event = 'TextYankPost',
            buffer = event.buf,
          })
          return
        end

        local group = 'editable-term-text-change' .. event.buf
        vim.iter(vim.api.nvim_get_autocmds({ group = group, event = 'TextYankPost', buffer = event.buf })):each(
          ---@param autocmd { id: integer, callback: fun(args: vim.api.keyset.create_autocmd.callback_args): boolean? }
          function(autocmd)
            vim.api.nvim_del_autocmd(autocmd.id)
            vim.api.nvim_create_autocmd('TextYankPost', {
              group = group,
              buffer = event.buf,
              ---@param args vim.api.keyset.create_autocmd.callback_args
              ---@return boolean?
              callback = function(args)
                if vim.v.event.operator ~= 'y' then
                  return autocmd.callback(args)
                end
              end,
            })
          end
        )
      end,
    })
  end,
}
