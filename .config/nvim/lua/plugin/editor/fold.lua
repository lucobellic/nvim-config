vim.o.foldcolumn = '0'
vim.o.foldenable = false
vim.o.foldmethod = 'syntax'


-- fold:c	'·' or '-'	filling 'foldtext'
-- foldopen:c	'-'		mark the beginning of a fold
-- foldclose:c	'+'		show a closed fold
-- foldsep:c	'│' or '|'      open fold middle marker
vim.opt.fillchars = {foldopen = '-', foldclose='-', foldsep = ' ', fold = ' '}

function _G.custom_fold_text()
    local line = vim.fn.getline(vim.v.foldstart)
    local line_count = vim.v.foldend - vim.v.foldstart + 1
    return line .. ' ... ' .. line_count
end

vim.o.foldtext = 'v:lua.custom_fold_text()'
