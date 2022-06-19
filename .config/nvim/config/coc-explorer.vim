
let g:coc_explorer_global_presets = {
      \   '.vim': {
      \     'root-uri': '~/.vim',
      \   },
      \   'cocConfig': {
      \      'root-uri': '~/.config/coc',
      \   },
      \   'tab': {
      \     'position': 'tab',
      \     'quit-on-open': v:true,
      \   },
      \   'floatingLeftside': {
      \     'position': 'floating',
      \     'floating-position': 'left-center',
      \     'floating-width': 50,
      \     'open-action-strategy': 'sourceWindow',
      \   },
      \   'floatingRightside': {
      \     'position': 'floating',
      \     'floating-position': 'right-center',
      \     'floating-width': 50,
      \     'open-action-strategy': 'sourceWindow',
      \   },
      \   'simplify': {
      \     'buffer-root-template': '',
      \     'file-root-template': ' [fullpath]',
      \     'file-child-template': '  [indent][icon | 1] [selection | clip][filename omitCenter 1][1 & git]',
      \     'explorer.git.icon.status.modified': '~',
      \     'explorer.git.icon.status.added': '+',
      \     'explorer.git.icon.status.deleted': '✗',
      \     'explorer.git.icon.status.ignored': '',
      \   },
      \   'buffer': {
      \     'position': 'floating',
      \     'floating-position': 'center',
      \     'floating-width': 120,
      \     'sources': [{'name': 'buffer', 'expand': v:true}]
      \   },
      \ }

let g:coc_default_semantic_highlight_groups = v:true

" Use preset argument to open it
nmap <silent> <leader>ee :CocCommand explorer --preset simplify<CR>
nnoremap <silent> <leader>er :call CocAction('runCommand', 'explorer.doAction', 'closest', ['reveal:0'], [['relative', 0, 'file']])<CR>

