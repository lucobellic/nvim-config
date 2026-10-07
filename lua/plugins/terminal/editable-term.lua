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

    -- Run after the plugin attaches so copying cannot interrupt OpenCode.
    vim.api.nvim_create_autocmd('TermOpen', {
      group = vim.api.nvim_create_augroup('EditableTermOpenCode', { clear = true }),
      ---@param event vim.api.keyset.create_autocmd.callback_args
      callback = function(event)
        if vim.bo[event.buf].filetype == 'opencode' then
          vim.api.nvim_clear_autocmds({
            group = 'editable-term-text-change' .. event.buf,
            event = 'TextYankPost',
            buffer = event.buf,
          })
        end
      end,
    })
  end,
}
