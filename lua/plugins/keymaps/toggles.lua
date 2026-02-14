local number = false
local relative_number = false

return {
  'folke/which-key.nvim',
  keys = {
    {
      '<leader>ul',
      function()
        number = not number
        vim.opt.number = number
        vim.opt.relativenumber = number and relative_number
      end,
      desc = 'Toggle Line Number',
    },
    {
      '<leader>uL',
      function()
        relative_number = not relative_number
        if number then
          vim.opt.relativenumber = relative_number
        end
      end,
      desc = 'Toggle Relative Line Number',
    },
    { '<leader>u=', '<cmd>ToggleFocusResize<cr>', desc = 'Toggle Focus Resize' },
    {
      '<leader>uw',
      function() vim.opt_local.wrap = not vim.opt_local.wrap:get() end,
      repeatable = true,
      desc = 'Toggle Auto Wrap',
    },
    { '<leader>uW', '<cmd>ToggleAutoSave<cr>', desc = 'Toggle Auto Save' },
    {
      '<leader>uh',
      function()
        local is_enabled = vim.lsp.inlay_hint.is_enabled()
        vim.lsp.inlay_hint.enable(not is_enabled)

        -- Sync mutable reference hints (inverse of inlay hints)
        local ok, mutable_ref_hints = pcall(require, 'util.mutable_reference_hints')
        if ok then
          mutable_ref_hints.sync_with_inlay_hints()
        end

        local text = (not is_enabled and 'Enabled' or 'Disabled') .. ' inlay hints'
        local level = not is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(text, level, { title = 'Options' })
      end,
      repeatable = true,
      desc = 'Toggle Inlay Hints',
    },
  },
}
