set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

function! CocPostInstall(info)
  if a:info.status == 'installed' || a:info.force
    :CocInstall coc-explorer coc-json coc-fzf-preview coc-snippets coc-highlight coc-python coc-rls coc-rust-analyzer coc-toml coc-yaml coc-cmake coc-vimlsp coc-clangd vim-lsp-cxx-highlight
  endif
endfunction

call plug#begin('~/.vim/plugged')

" Completion & Languages
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': function('CocPostInstall')}
Plug 'rust-lang/rust.vim'
Plug 'liuchengxu/vista.vim'

" Navigation
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf' ", { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vim-clap' ", { 'do': ':Clap install-binary' }

" Themes
" Use private personal configuration of ayu theme
Plug 'git@gitlab.com:luco-bellic/ayu-vim.git', { 'branch': 'personal' }
"Plug 'Luxed/ayu-vim'
Plug 'frazrepo/vim-rainbow'
Plug 'jackguo380/vim-lsp-cxx-highlight'

" Icons
Plug 'kyazdani42/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'

" UI
"Plug 'wfxr/minimap.vim'
Plug 'psliwka/vim-smoothie' " or Plug 'yuttie/comfortable-motion.vim'
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
Plug 'mhinz/vim-startify'    " Start screen
Plug 'junegunn/goyo.vim'     " Zen mode
Plug 'voldikss/vim-floaterm' " Flaoting terminal
"Plug 'glepnir/galaxyline.nvim' , {'branch': 'main'}
"Plug 'camspiers/animate.vim' " Animation with lens.vim
"Plug 'camspiers/lens.vim'    " Automatic window resize
Plug 'onsails/lspkind-nvim' " Pictogram for neovim


Plug 'airblade/vim-gitgutter' " Plug 'lewis6991/gitsigns.nvim'
Plug 'itchyny/lightline.vim'

" Other
Plug 'jceb/vim-orgmode'
Plug 'xolox/vim-misc'
Plug 'moll/vim-bbye'
Plug 'honza/vim-snippets'

call plug#end()

" ----------------- Start Screen ----------------- "
" Handle new tab with goyo
" autocmd BufEnter *
"        \ if !exists('t:startify_new_tab') && empty(expand('%')) && !exists('t:goyo_master') |
"        \   let t:startify_new_tab = 1 |
"        \   Startify |
"        \ endif

let g:start_screen_ascii = [
      \ '       ______________________________________________________________________________________________________________________________________ ',
      \ '      /_____/￣\ ___________________________________________________/￣￣￣￣\ _______________/￣\ ______/￣\ ______/￣\ ___________________/ ',
      \ '     /_____/￣\/_______/￣\____/￣\ __/￣￣￣\ ___/￣￣￣\ ________/￣\__/￣\/__/￣￣￣￣\ __/￣\/______/￣\/_____________/￣￣￣\ ________/ ',
      \ '    /_____/￣\/_______/￣\/___/￣\/__/￣\ _____/￣\_____/￣\ _____/￣￣￣￣\ __/￣\__/￣\/__/￣\/______/￣\/______/￣\ __/￣\ ____________/ ',
      \ '   /_____/￣\/_______/￣\/___/￣\/__/￣\/_____/￣\/____/￣\/_____/￣\__/￣\ __/￣\/________/￣\/______/￣\/______/￣\/__/￣\/____________/ ',
      \ '  /_____/￣￣￣￣\ _/￣￣￣￣￣\/__/￣￣￣\ ___/￣￣￣\ ________/￣￣￣￣\/__/￣￣￣￣\ __/￣￣￣\ __/￣￣￣\ __/￣\/__/￣￣￣\ ________/ ',
      \ ' /_____________________________________________________________________________________________________________________________________/ ',
      \ ''
      \]

let g:start_screen_ascii_2 = [
      \ '                            ______/￣\ ___________________________________________________         ',
      \ '                           /_____/￣\/_______/￣\____/￣\ __/￣￣￣\ ___/￣￣￣\ ________/        ',
      \ '                          /_____/￣\/_______/￣\/___/￣\/__/￣\ _____/￣\_____/￣\ _____/        ',
      \ '                         /_____/￣\/_______/￣\/___/￣\/__/￣\/_____/￣\/____/￣\/_____/        ',
      \ '                        /_____/￣￣￣￣\ _/￣￣￣￣￣\/__/￣￣￣\ ___/￣￣￣\ ________/        ',
      \ '                       /_____________________________________________________________/        ',
      \ '                                                                                               ',
      \ '                 ______/￣￣￣￣\ _______________/￣\ ______/￣\ ______/￣\ ________________  ',
      \ '                /_____/￣\__/￣\/__/￣￣￣￣\ __/￣\/______/￣\/_____________/￣￣￣\ _____/ ',
      \ '               /_____/￣￣￣￣\ __/￣\__/￣\/__/￣\/______/￣\/______/￣\ __/￣\ _________/ ',
      \ '              /_____/￣\__/￣\ __/￣\/________/￣\/______/￣\/______/￣\/__/￣\/_________/ ',
      \ '             /_____/￣￣￣￣\/__/￣￣￣￣\ __/￣￣￣\ __/￣￣￣\ __/￣\/__/￣￣￣\ _____/ ',
      \ '            /__________________________________________________________________________/ ',
      \ ''
      \]

let g:startify_custom_header =
      \ 'startify#center(g:start_screen_ascii_2)'
      " \ 'startify#center(g:start_screen_ascii_2) + startify#center(startify#fortune#boxed())'

let g:startify_disable_at_vimenter = 0

" ------------------- Editor -------------------- "

set clipboard+=unnamedplus
let mapleader="\<SPACE>"
set number
set signcolumn=number
set cursorline
set noswapfile
"set autoread
"set autowriteall
"autocmd TextChanged,TextChangedI <buffer> silent! write
set noshowmode " Disable -- INSERT -- and similar
set wrap! " Disable wrapping
set wmw=0 " Minimum window width
set wmh=0 " Minimum window height
set ignorecase
autocmd BufEnter * silent! :Glcd

" Tabulation improvement
set wildmode=longest:full,full
set wildmenu

" tab/space behavior
set tabstop=2
set expandtab
set shiftwidth=2
set smarttab

" Removes trailing spaces
function! Preserve(command)
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " Do the business:
  execute a:command
  " Clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

"map = :call Preserve("%s/\\s\\+$//e")<CR>
set list
set showbreak=↪
"set listchars=tab:→\ ,eol:↲,nbsp:␣
set listchars=tab:-\ ,trail:·,extends:⟩,precedes:⟨
set fillchars=vert:\

" which-key configuration
let g:mapleader = "\<Space>"
"let g:maplocalleader = ','
nnoremap <silent> <leader>  :WhichKey '<Space>'<CR>
nnoremap <silent> <leader>  :<c-u>WhichKey '<Space>'<CR>
"nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
set timeoutlen=500

" Snippets completion
inoremap <silent><expr> <TAB>
			\ pumvisible() ? coc#_select_confirm() :
			\ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
			\ <SID>check_back_space() ? "\<TAB>" :
			\ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Zen mode activation
let g:goyo_width = 120
let g:goyo_height = '90%'
let g:goyo_linenr = 1
nnoremap <silent> <C-z> :<C-u>Goyo<CR>

let g:lens#disabled_filetypes = ['nerdtree', 'fzf', 'coc-explorer', 'Goyo']

" Bottom terminal with defined height
nnoremap <silent> <leader>p      :<C-u>bo 20split tmp<CR>:terminal<CR>

" Floating terminal
nnoremap <silent> <F7>           :FloatermToggle<CR>
tnoremap <silent> <F7>           <C-\><C-n>:FloatermToggle<CR>

nnoremap <silent> <C-p>          :<C-u>:Clap! files<CR>
nnoremap <silent> <leader>mp     :<C-u>:Clap! files<CR>
nnoremap <silent> <leader>my     :<C-u>:Clap yanks<CR>
nnoremap <silent> <leader>mb     :<C-u>:Clap buffers<cr>
nnoremap <silent> <leader>mf     :<C-u>:Clap blines<CR>
nnoremap <silent> <leader>mF     :<C-u>:Rg<CR>
nnoremap <silent> <C-S-f>        :<C-u>:Rg<CR>
nnoremap <silent> <leader>ml     :<C-u>:Clap! lines<CR>
nnoremap <silent> <leader>m'     :<C-u>:Clap! marks<CR>
nnoremap <silent> <leader>ef     :<C-u>:Clap! filer<CR>

nnoremap <silent> <leader>mo     :<C-u>Vista!!<CR>
nnoremap <silent> <leader>mO     :<C-u>:Clap tags<CR>
nnoremap <silent> <leader>o      :<C-u>Vista focus<CR>

" nnoremap <silent> <leader>m<C-o> :<C-u>CocCommand fzf-preview.Jumps<CR>
" nnoremap <silent> <leader>m/     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
" nnoremap <silent> <leader>m*     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>

" Project Grep
" nnoremap          <leader>mgr    :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
" xnoremap          <leader>mgr    :<C-u>CocCommand fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
" nnoremap <silent> <leader>mt     :<C-u>CocCommand fzf-preview.BufferTags<CR>
" nnoremap <silent> <leader>mq     :<C-u>CocCommand fzf-preview.QuickFix<CR>

" Git command
" nnoremap <silent> <leader>gs     :<C-u>CocCommand fzf-preview.GitStatus<CR>
" nnoremap <silent> <leader>ga     :<C-u>CocCommand fzf-preview.GitActions<CR>
nnoremap <silent> <leader>g;     :<C-u>Commits<CR>
nnoremap <silent> <leader>gc     :<C-u>Git commit<CR>
nnoremap <silent> <leader>ga     :<C-u>Git commit --amend<CR>

" Windows resizing
nnoremap <silent> <C-left>      :vertical resize +5<cr>
nnoremap <silent> <C-up>        :resize +5<cr>
nnoremap <silent> <C-down>      :resize -5<cr>
nnoremap <silent> <C-right>     :vertical resize -5<cr>
nnoremap <silent> <S-left>      <C-w>h
nnoremap <silent> <S-up>        <C-w>k
nnoremap <silent> <S-down>      <C-w>j
nnoremap <silent> <S-right>     <C-w>l
" nnoremap <silent> <C-h>         <C-w>h
" nnoremap <silent> <C-k>         <C-w>k
" nnoremap <silent> <C-j>         <C-w>j
" nnoremap <silent> <C-l>         <C-w>l
"
" ----------------- Navigation ------------------ "

nnoremap <silent> <leader>1 1gt
nnoremap <silent> <leader>2 2gt
nnoremap <silent> <leader>3 3gt
nnoremap <silent> <leader>4 4gt
nnoremap <silent> <leader>5 5gt
nnoremap <silent> <leader>6 6gt
nnoremap <silent> <leader>7 7gt
nnoremap <silent> <leader>8 8gt
nnoremap <silent> <leader>9 9gt

nnoremap <silent> <leader>th :tabprev<CR>
nnoremap <silent> <leader>tl :tabnext<CR>
nnoremap          <leader>tt :tabedit<Space>
nnoremap <silent> <leader>tn :tabnew<CR>
nnoremap          <leader>tm :tabm<Space>
nnoremap <silent> <leader>tq :tabclose<CR>

" Move to line
nmap <leader>l <Plug>(easymotion-bd-jk)
nmap <leader>L <Plug>(easymotion-overwin-line)

" Move to word
map  <leader>j <Plug>(easymotion-bd-w)
nmap <leader>J <Plug>(easymotion-overwin-w)

let s:hidden_all = 0
function! ToggleHiddenAll()
  if s:hidden_all  == 0
    let s:hidden_all = 1
    set noshowmode
    set noruler
    set laststatus=0
    set noshowcmd
  else
    let s:hidden_all = 0
    set showmode
    set ruler
    set laststatus=2
    set showcmd
  endif
endfunction
"nnoremap <C-h> :call ToggleHiddenAll()<CR>

nmap <H <Plug>(GitGutterPrevHunk)
nmap >H <Plug>(GitGutterNextHunk)
nmap <Leader>hv <Plug>(GitGutterPreviewHunk)

nnoremap <silent> <Esc>       :nohl<CR>
map               <leader>w   <C-w>
nnoremap <silent> <leader>wd  :Bdelete<CR>

" Escape terminal insert mode and floating terminal
tnoremap <Esc> <C-\><C-n>

"let g:EasyMotion_do_mapping = 0 " Disable default mappings
map <leader><leader> <Plug>(easymotion-prefix)
map <leader>s        <Plug>(easymotion-s)

let g:EasyMotion_smartcase         = 1 " Turn on case-insensitive 
let g:EasyMotion_use_smartsign_us  = 1 " Match both '1' and '!'
let g:EasyMotion_off_screen_search = 0 " Do not search outside the screen range
let g:EasyMotion_do_shade          = 1


" ---------------- Color & Scheme --------------- "

set termguicolors     " enable true colors support
set background=dark
"set ayucolor="dark"   " for dark version of theme
colorscheme ayu

" Use vim-devicons
let g:fzf_preview_use_dev_icons = 0

" devicons character width
let g:fzf_preview_dev_icon_prefix_string_length = 3

" Devicons can make fzf-preview slow when the number of results is high
" By default icons are disable when number of results is higher that 5000
let g:fzf_preview_dev_icons_limit = 5000

let g:rainbow_active = 1

let g:rainbow_load_separately = [
		\ [ '*' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
    \ [ '*.tex' , [['(', ')'], ['\[', '\]']] ],
    \ [ '*.cpp' , [['(', ')'], ['\[', '\]'], ['{', '}']] ],
    \ [ '*.{html,htm}' , [['(', ')'], ['\[', '\]'], ['{', '}'], ['<\a[^>]*>', '</[^>]*>']] ],
    \ ]

let g:rainbow_guifgs = ['Gold', 'Orchid', 'LightSkyBlue', 'DarkOrange']
" let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'yellow', 'red', 'magenta']

hi link LspCxxHlSymParameter Constant
hi link LspCxxHlSymField Todo
hi link ClapPreview Normal
hi link ClapDisplay Normal
hi link ClapCurrentSelection CursorLine

let g:markdown_fenced_languages = [
      \ 'vim',
      \ 'help'
      \]

" transparent bg
function! Transparency()
	hi Normal guibg=none ctermbg=none
	hi CursorColumn guibg=none ctermbg=none
	hi CursorLine guibg=none ctermbg=none
	hi CursorLineNr guibg=none ctermbg=none
	hi LineNr guibg=none ctermbg=none
	hi Folded guibg=none ctermbg=none
	hi NonText guibg=none ctermbg=none
	hi SpecialKey guibg=none ctermbg=none
	hi VertSplit guibg=none ctermbg=none
	hi SignColumn guibg=none ctermbg=none
	hi Pmenu guibg=none ctermbg=none
	hi StatusLine guibg=none ctermbg=none
	hi LightlineMiddle_inactive guibg=none ctermbg=none
	hi LightlineMiddle_active guibg=none ctermbg=none
	hi VertSplit guibg=none ctermbg=none
endfunction

" autocmd vimenter * call Transparency()
" autocmd ColorScheme * call Transparency()

" -------- fzf and vista configuration ---------- "

"let g:clap_no_matches_msg = "¯\\_(ツ)_/¯"
"let g:clap_preview_size = { '*': 5, 'files': 10 }
let g:clap_preview_direction = 'UD' "Upside down preview display
let g:clap_layout = { 'relative': 'editor', 'row': '2%'} " Relative to the whole editor
"let g:clap_layout:  { 'width': '67%', 'height': '33%', 'row': '33%', 'col': '17%' }
let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.7, 'border': 'none', 'highlight': 'Comment' } }
let g:rg_derive_root='true'

let g:vista_default_executive = 'coc'
let g:vista_sidebar_width = 50
let g:vista_echo_cursor_startegy = 'scroll'
let g:vista_echo_cursor = 0
let g:vista_keep_fzf_colors = 1
let g:vista_enable_centering_jump = 0

let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow'

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--info=inline']}, <bang>0)

command! -bang -nargs=* Rg
			\ call fzf#vim#grep(
			\   'rg --line-number --color=always --smart-case --hidden -- '.shellescape(<q-args>), 0,
			\   fzf#vim#with_preview(), <bang>0)

" ----------- coc.vim configuration ------------- "

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Space for displaying messages.
set cmdheight=1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

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

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> <C <Plug>(coc-diagnostic-prev)
nmap <silent> >C <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

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
autocmd CursorHold * silent call CocActionAsync('highlight')

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
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>cac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>cf  <Plug>(coc-fix-current)

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

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Use vista.vim to display function
function! NearestMethodOrFunction() abort
  return get(b:, 'vista_nearest_method_or_function', '')
endfunction


" Nearest function in statusline
autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

" ['cocstatus', 'lineinfo']
let g:lightline = {
      \ 'colorscheme': 'ayu',
      \ 'active': {
      \   'left': [ [ 'm', 'paste' ],
      \             [ 'gitbranch' ],
      \             [ 'readonly', 'filename', 'modified' ] ],
      \   'right': [ ['method'] ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'gitbranch': 'FugitiveHead',
      \   'method': 'NearestMethodOrFunction',
      \   'm': 'LightMode'
      \ },
      \ }

" Use autocmd to force lightline update.
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

function! ExplorerCurDir()
  let node_info = CocAction('runCommand', 'explorer.getNodeInfo', 0)
  return fnamemodify(node_info['fullpath'], ':h')
endfunction

function! LightMode()
  let l:m = mode()
  return toupper(m)
endfunction

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
			\     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
			\   },
			\   'buffer': {
			\     'position': 'floating',
			\     'floating-position': 'center',
			\     'floating-width': 120,
			\     'sources': [{'name': 'buffer', 'expand': v:true}]
			\   },
			\ }

" Use preset argument to open it
nmap <silent><leader>eb :CocCommand explorer --preset buffer<CR>
nmap <silent><leader>ee :CocCommand explorer --preset simplify<CR>
