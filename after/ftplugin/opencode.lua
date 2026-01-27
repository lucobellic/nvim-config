vim.keymap.set({ 'n', 't', 'i' }, '<A-l>', '<cmd>OpenCodeNext<cr>', { buffer = true })
vim.keymap.set({ 'n', 't', 'i' }, '<A-h>', '<cmd>OpenCodePrev<cr>', { buffer = true })
vim.keymap.set({ 'n', 't', 'i' }, '<C-q>', '<cmd>OpenCodeClose<cr>', { buffer = true })
vim.keymap.set({ 'n' }, '<C-t>', '<cmd>OpenCodeNew<cr>', { buffer = true })
