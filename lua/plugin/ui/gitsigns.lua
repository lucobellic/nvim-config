require('gitsigns').setup {
  signs                             = {
    add          = { hl = 'GitSignsAdd', text = '▕', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
    change       = { hl = 'GitSignsChange', text = '▕', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
    delete       = { hl = 'GitSignsDelete', text = '▕', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    topdelete    = { hl = 'GitSignsDelete', text = '▕', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    changedelete = { hl = 'GitSignsChange', text = '▕', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
  },
  signcolumn                        = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl                             = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl                            = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff                         = false, -- Toggle with `:Gitsigns toggle_word_diff`
  keymaps                           = {
    -- Default keymap options
    noremap = true,
    silent = true,

    ['n >H'] = { expr = true, "&diff ? '>H' : '<cmd>silent lua require\"gitsigns.actions\".next_hunk()<CR>'" },
    ['n <H'] = { expr = true, "&diff ? '<H' : '<cmd>silent lua require\"gitsigns.actions\".prev_hunk()<CR>'" },

    ['n <leader>hs'] = '<cmd>Gitsigns stage_hunk<CR>',
    ['v <leader>hs'] = ':Gitsigns stage_hunk<CR>',
    ['n <leader>hu'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
    ['n <leader>hr'] = '<cmd>Gitsigns reset_hunk<CR>',
    ['v <leader>hr'] = ':Gitsigns reset_hunk<CR>',
    ['n <leader>hR'] = '<cmd>Gitsigns reset_buffer<CR>',
    ['n <leader>hv'] = '<cmd>Gitsigns preview_hunk<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
    ['n <leader>hS'] = '<cmd>Gitsigns stage_buffer<CR>',
    ['n <leader>hU'] = '<cmd>Gitsigns reset_buffer_index<CR>',
    ['n <leader>ht'] = '<cmd>Gitsigns toggle_current_line_blame<CR>',

    -- Text objects
    ['o ih'] = ':<C-U>Gitsigns select_hunk<CR>',
    ['x ih'] = ':<C-U>Gitsigns select_hunk<CR>'
  },
  watch_gitdir                      = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked               = true,
  current_line_blame                = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts           = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
  },
  current_line_blame_formatter_opts = {
    relative_time = false
  },
  sign_priority                     = 30,
  update_debounce                   = 100,
  status_formatter                  = nil, -- Use default
  max_file_length                   = 40000,
  preview_config                    = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  yadm                              = {
    enable = false
  },
  -- Solve CRLF issue with gitsigns
  diff_opts                         = {
    internal = false
  }
}
-- gs.setup {
-- signs = {
--     add = {hl = "DiffAdd", text = '▏', numhl = "GitSignsAddNr"},
--     change = {hl = "DiffChange", text = '▏', numhl = "GitSignsChangeNr"},
--     delete = {hl = "DiffDelete", text = '▏', numhl = "GitSignsDeleteNr"},
--     topdelete = {hl = "DiffDelete", text = '▏', numhl = "GitSignsDeleteNr"},
--     changedelete = {hl = "DiffChange", text = '▏', numhl = "GitSignsChangeNr"}
-- },
-- numhl = false,
-- keymaps = {
--     -- Default keymap options
--     noremap = true,
--     buffer = true,
--     ["n >h"] = {expr = true, '&diff ? \']c\' : \'<cmd>lua require"gitsigns".next_hunk()<CR>\''},
--     ["n <h"] = {expr = true, '&diff ? \'[c\' : \'<cmd>lua require"gitsigns".prev_hunk()<CR>\''},
--     ["n <leader>hs"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
--     ["n <leader>hu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
--     ["n <leader>hr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
--     ["n <leader>hv"] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
--     ["n <leader>hb"] = '<cmd>lua require"gitsigns".blame_line()<CR>'
-- },
-- watch_index = {
--     interval = 100
-- },
-- sign_priority = 5,
-- status_formatter = nil -- Use default
-- }
