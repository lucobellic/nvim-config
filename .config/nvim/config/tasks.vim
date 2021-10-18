let g:asyncrun_open = 6
let g:asyncrun_rootmarks = ['.git', '.svn', '.root', '.project', '.hg']
let g:asynctasks_term_pos = 'bottom'
let g:asynctasks_term_rows = 10

noremap <silent><f5> :AsyncTask run<cr>
noremap <silent><f9> :AsyncTask build<cr>
