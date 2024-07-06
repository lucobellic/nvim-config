" Vim syntax file
" Language: ezi-lang
" Latest Revision: 27 November 2019
" Installation:
"  * Move this file to '~/.vim/syntax/ezi.vim'
"  * Add the following line in your '.vimrc': "au BufRead,BufNewFile *.ezi set filetype=ezi"
if exists("b:current_syntax")
  finish
endif
""""""""""""""""""""""""""""""
" Keywords
""""""""""""""""""""""""""""""
syn keyword eziImport import
syn keyword eziStructure struct variant enum node interface
syn keyword eziSpecialStructure params properties
syn keyword eziLabel public_ref contained containedin=eziBlock
syn keyword eziPropertyNames customValidate contained containedin=eziBlock
syn keyword eziType int string bool uint double list optional test refvalue
syn keyword eziBool true false
""""""""""""""""""""""""""""""
" Comment
""""""""""""""""""""""""""""""
syn match eziComment "//.*$" contains=eziTodo
syn keyword eziTodo TODO FIXME XXX NOTE contained
"""""""""""""""""""""""""""""
" Validators
"""""""""""""""""""""""""""""
syn region eziValidators start="\[" end="\]" transparent contains=eziValidator,eziRangeSep
syn keyword eziValidator min max minExclusive maxExclusive range contained
syn match eziRangeSep "\.\." contained
""""""""""""""""""""""""""""""
" Regions
""""""""""""""""""""""""""""""
syn region eziBlock start="{" end="}" fold transparent
syn region eziString start=+"+ skip=+\\"+ end=+"+
""""""""""""""""""""""""""""""
" Setup syntax highlighting
""""""""""""""""""""""""""""""
let b:current_syntax = "ezi"
hi def link eziImport             Include
hi def link eziStructure          Structure
hi def link eziSpecialStructure   Statement
hi def link eziLabel              Label
hi def link eziType               Type
hi def link eziValidator          Identifier
hi def link eziPropertyNames      Identifier
hi def link eziBool               Boolean
hi def link eziComment            Comment
hi def link eziTodo               Todo
hi def link eziString             String
hi def link eziRangeSep           Operator
