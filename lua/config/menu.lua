vim.cmd([[
  aunmenu   PopUp
  anoremenu PopUp.Inspect    <cmd>Inspect<CR>
  amenu     PopUp.-1-        <Nop>
  anoremenu PopUp.Definition <cmd>Telescope lsp_definitions<CR>
  anoremenu PopUp.References <cmd>Telescope lsp_references<CR>
  amenu     PopUp.-2-        <Nop>
  amenu     PopUp.URL        gx
  amenu     PopUp.-3-        <Nop>
  nnoremenu PopUp.Back       <C-o>
]])

local group = vim.api.nvim_create_augroup('nvim_popupmenu', { clear = true })
vim.api.nvim_create_autocmd('MenuPopup', {
  pattern = '*',
  group = group,
  desc = 'Custom PopUp Setup',
  callback = function()
    vim.cmd([[
      amenu disable PopUp.Definition
      amenu disable PopUp.References
      amenu disable PopUp.URL
    ]])

    if vim.lsp.get_clients({ bufnr = 0 }) then
      vim.cmd([[
      amenu enable PopUp.Definition
      amenu enable PopUp.References
      ]])
    end

    local urls = require('vim.ui')._get_urls()
    if vim.startswith(urls[1], 'http') then
      vim.cmd([[amenu enable PopUp.URL]])
    end
  end,
})
