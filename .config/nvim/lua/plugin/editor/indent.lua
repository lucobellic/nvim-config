-- default options
-- require('indent_guides').setup({
--   indent_levels = 30;
--   indent_guide_size = 1;
--   indent_start_level = 1;
--   indent_enable = true;
--   indent_space_guides = true;
--   indent_tab_guides = false;
--   indent_soft_pattern = '\\s';
--   exclude_filetypes = {'help','dashboard','dashpreview','NvimTree','vista','sagahover'};
--   even_colors = { fg ='#2a3834',bg='#332b36' };
--   odd_colors = {fg='#332b36',bg='#2a3834'};

-- })
--
--
vim.cmd [[hi IndentBlanklineChar guifg=#0D1319 gui=nocombine]]
vim.cmd [[hi IndentBlanklineContextChar guifg=#6C7380 gui=nocombine]]
-- vim.cmd [[hi IndentBlanklineContextChar guifg=#D2A6FF gui=nocombine]]

require('indent_blankline').setup {
  enabled = true,
  use_treesitter = true,
  use_treesitter_scope = true,
  show_current_context = true,
  show_current_context_start = false,
  show_trailing_blankline_indent = true,
  char = '▏',
  filetype_exclude = {
    'help',
    'nerdtree',
    'vista',
    'dashboard',
    'coc-explorer',
    'floaterm',
    'telescope',
    'Telescope',
    'TelescopePrompt',
    'telescopeprompt',
    'clap_input',
    'clap'
  },
  context_patterns = {
    "class",
    "^func",
    "method",
    "^if",
    "while",
    "for",
    "with",
    "try",
    "except",
    "arguments",
    "argument_list",
    "object",
    "dictionary",
    "element",
    "table",
    "tuple",
    "do_block",
    "def",
  }
}
