vim.keymap.set({'n', 't', 'i'}, '<A-l>', '<cmd>CursorAgentNext<cr>', { buffer = true })
vim.keymap.set({'n', 't', 'i'}, '<A-h>', '<cmd>CursorAgentPrev<cr>', { buffer = true })
vim.keymap.set({'n', 't', 'i'}, '<C-t>', '<cmd>CursorAgentNew<cr>', { buffer = true })
vim.keymap.set({'n', 't', 'i'}, '<C-q>', '<cmd>CursorAgentClose<cr>', { buffer = true })
