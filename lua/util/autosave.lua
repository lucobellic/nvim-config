---@class AutosaveUtil
---@field private autocmd_save_id number
local M = {}

function M.create_autosave_autocmd()
  return vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
    pattern = '*',
    callback = function(ev)
      local markdown = vim.bo.filetype == 'markdown' -- markdown file may contains 2 spaces at eol
      local modified = vim.bo.modifiable and vim.bo.modified
      local not_popup = vim.fn.pumvisible() == 0 -- or vim.api.nvim_win_get_config(0).zindex
      if not markdown and modified and not_popup then
        -- Save and restore cursor position
        local cursor = vim.api.nvim_win_get_cursor(0)
        -- Remove trailing whitespace
        vim.cmd('silent! %s/\\s\\+$//e')
        vim.cmd('silent! write')
        vim.api.nvim_win_set_cursor(0, cursor)
      end
    end,
    desc = 'Automatic save after insertion leave',
  })
end

function M.setup()
  M.autocmd_save_id = M.create_autosave_autocmd()

  vim.api.nvim_create_user_command('ToggleAutoSave', function()
    if M.autocmd_save_id ~= 0 then
      vim.api.nvim_del_autocmd(M.autocmd_save_id)
      M.autocmd_save_id = 0
    else
      M.autocmd_save_id = M.create_autosave_autocmd()
    end
  end, { desc = 'Toggle Auto Save' })
end

return M
