-- TODO: Replace this vim code to lua
vim.cmd[[
function! GetBufnrUnnamed() abort
  let buflist = floaterm#buflist#gather()
  for bufnr in buflist
    let name = getbufvar(bufnr, 'floaterm_name')
    if empty(name)
      return bufnr
    endif
  endfor
  return -1
endfunction

function! ToggleTool(tool, count) abort
  " find bufnr according to the tool name
  let bufnr = empty(a:tool) ?
    \ GetBufnrUnnamed() : floaterm#terminal#get_bufnr(a:tool)

  if bufnr == -1
    if empty(a:tool)
      " ToggleTool should only be called from
      " normal mode or terminal mode without bang
      call floaterm#run('new', 0, [visualmode(), 0, 0, 0], '')
    else
      call floaterm#run('new', 0, [visualmode(), 0, 0, 0],
        \ printf('--height=0.8 --width=0.8 --title=%s($1/$2) --name=%s %s', a:tool, a:tool, a:tool))
    endif
  else
    call floaterm#toggle(0, a:count ? a:count : bufnr, '')
    " workaround to prevent lazygit shift left;
    " another workaround here is to use sidlent!
    " to ignore can't re-enter normal mode error
    execute('silent! normal! 0')
  endif
endfunction

command! -nargs=? -count=0 ToggleTool call ToggleTool(<q-args>, <count>)
nnoremap <silent> <leader>g; <Cmd>execute v:count . 'ToggleTool lazygit'<CR>
tnoremap <silent> <leader>g; <Cmd>execute v:count . 'ToggleTool lazygit'<CR>
]]


vim.g.floaterm_autoclose = 1 -- Close only if the job exits normally
vim.g.floaterm_autohide = 1
-- vim.g.floaterm_borderchars = '       ' -- (top, right, bottom, left, topleft, topright, botright, botleft)
-- vim.g.floaterm_borderchars = '─│─│╭╮╯╰'
vim.g.floaterm_borderchars = '─│─│┌┐┘└'
vim.g.floaterm_autoinsert = true
