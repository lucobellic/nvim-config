if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.bpl setfiletype xml
  au! BufRead,BufNewFile *.simvis setfiletype xml
augroup END
