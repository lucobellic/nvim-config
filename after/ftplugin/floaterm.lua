local opts = { silent = true, noremap = true }

vim.api.nvim_buf_set_keymap(0, 'n', 'q', ':FloatermHide<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 'n', '<esc>', ':FloatermHide<CR>', opts)

vim.api.nvim_buf_set_keymap(0, 'n', '<C-q>', ':FloatermKill<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 't', '<C-q>', '<C-\\><C-n>:FloatermKill<CR>', opts)

vim.api.nvim_buf_set_keymap(0, 'n', '<C-l>', ':FloatermNext<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', '<C-\\><C-n>:FloatermNext<CR>', opts)

vim.api.nvim_buf_set_keymap(0, 'n', '<C-h>', ':FloatermPrev<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', '<C-\\><C-n>:FloatermPrev<CR>', opts)

vim.api.nvim_buf_set_keymap(0, 'n', '<C-t>', ':FloatermNew<CR>', opts)
vim.api.nvim_buf_set_keymap(0, 't', '<C-t>', '<C-\\><C-n>:FloatermNew<CR>', opts)

vim.wo.spell = false

vim.b.miniindentscope_disable = true
vim.b.minianimate_disable = true

--- Open file path under cursor in a normal window from floaterm
local function open_in_normal_window()
  local file = vim.fn.findfile(vim.fn.expand("<cfile>"))
  if file ~= "" and vim.fn.has_key(vim.api.nvim_win_get_config(vim.fn.win_getid()), "anchor") then
    vim.fn.execute('FloatermHide')
    vim.fn.execute('e ' .. file)
  end
end

vim.api.nvim_create_user_command(
  'OpenInNormalWindow',
  open_in_normal_window,
  { desc = 'Open file in normal window from floating terminal' }
)

vim.api.nvim_buf_set_keymap(0, 'n', 'gf', ':OpenInNormalWindow<cr>', { noremap = true, silent = true })
