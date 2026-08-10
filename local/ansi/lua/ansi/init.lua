---@class Ansi
local M = {}

---Show an ANSI-rendered view of a buffer using Neovim's terminal emulator.
---@public
---@param bufnr? integer
---@return integer? channel
function M.render(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) or vim.api.nvim_get_current_buf() ~= bufnr then
    return nil
  end

  if vim.api.nvim_get_option_value('buftype', { buf = bufnr }) == 'terminal' then
    return nil
  end

  local rendered_buf = vim.api.nvim_create_buf(false, true)
  local source_bufhidden = vim.api.nvim_get_option_value('bufhidden', { buf = bufnr })
  vim.api.nvim_buf_set_lines(rendered_buf, 0, -1, false, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = rendered_buf })
  vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = bufnr })
  vim.b[rendered_buf].ansi_source = bufnr

  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = rendered_buf,
    once = true,
    callback = function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_set_option_value('bufhidden', source_bufhidden, { buf = bufnr })
      end
    end,
  })

  vim.api.nvim_win_set_buf(0, rendered_buf)

  return vim.api.nvim_open_term(rendered_buf, {})
end

---Toggle between an editable source buffer and its ANSI-rendered view.
---@public
function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  local source_buf = vim.b[bufnr].ansi_source

  if source_buf then
    if vim.api.nvim_buf_is_valid(source_buf) then
      vim.api.nvim_win_set_buf(0, source_buf)
    end
    return
  end

  M.render(bufnr)
end

---Enable native ANSI rendering for terminal filetypes and the `:Ansi` command.
---@public
function M.setup()
  local group = vim.api.nvim_create_augroup('AnsiRendering', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'terminal',
    callback = function(args) M.render(args.buf) end,
    desc = 'Render ANSI escapes with the native terminal emulator',
  })

  vim.api.nvim_create_user_command('Ansi', function() M.toggle() end, {
    desc = 'Toggle ANSI rendering in the current buffer',
  })
end

return M
