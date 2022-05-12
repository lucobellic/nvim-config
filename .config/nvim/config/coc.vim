" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `<C` and `>C` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <C <Plug>(coc-diagnostic-prev)
nmap <silent> >C <Plug>(coc-diagnostic-next)

" GoTo code navigation.
" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gy <Plug>(coc-type-definition)
" nmap <silent> gi <Plug>(coc-implementation)
" nmap <silent> gr <Plug>(coc-references)

nmap <silent> gd <cmd>Telescope coc definitions<cr>
nmap <silent> gy <cmd>Telescope coc declarations<cr>
nmap <silent> gi <cmd>Telescope coc implementations<cr>
nmap <silent> gr <cmd>Telescope coc references<cr>

" Show documentation in preview window.
nnoremap <silent> <leader>d :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
"autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>cr <Plug>(coc-rename)
nmap <F2>       <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

map <silent> <M-o> :CocCommand clangd.switchSourceHeader<CR>

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  " autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  " autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
" nmap <leader>ca  <Plug>(coc-codeaction)
nmap <silent> <leader>cd <cmd>Telescope coc workspace_diagnostics<cr>

" Apply AutoFix to problem on the current line.
nmap <silent> <leader>cf <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

function! ExplorerCurDir()
  let node_info = CocAction('runCommand', 'explorer.getNodeInfo', 0)
  return fnamemodify(node_info['fullpath'], ':h')
endfunction

" Snippets completion
inoremap <silent><expr> <TAB>
			\ pumvisible() ? coc#_select_confirm() :
			\ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
			\ <SID>check_back_space() ? "\<TAB>" :
			\ coc#refresh()

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

