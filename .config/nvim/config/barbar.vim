" NOTE: If barbar's option dict isn't created yet, create it
let bufferline = get(g:, 'bufferline', {})

" Enable/disable animations
let bufferline.animation = v:true

" Enable/disable auto-hiding the tab bar when there is a single buffer
let bufferline.auto_hide = v:true

" Enable/disable current/total tabpages indicator (top right corner)
let bufferline.tabpages = v:true

let bufferline.closable = v:false
let bufferline.clickable = v:false
let bufferline.icons = v:true

" Configure icons on the bufferline.
let bufferline.icon_separator_active = '▎'
let bufferline.icon_separator_inactive = ' '
let bufferline.icon_close_tab = ''
let bufferline.icon_close_tab_modified = ''

let bufferline.exclude_ft = ['coc-explorer']

let bufferline.semantic_letters = v:false
let bufferline.letters =
  \ 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP'

" Sets the maximum padding width with which to surround each tab
let bufferline.maximum_padding = 1

