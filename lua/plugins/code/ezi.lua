return {
  'nvim-treesitter/nvim-treesitter',
  enabled = false,
  opts = function(_, opts)
    local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    --- @diagnostic disable-next-line: inject-field
    parser_config.ezi = {
      install_info = {
        url = 'git@gitlab.easymile.com:blaiselcq/tree-sitter-ezi', -- local path or git repo
        files = { 'src/parser.c' }, -- note that some parsers also require src/scanner.c or src/scanner.cc
        branch = 'master', -- default branch in case of git repo if different from master
        generate_requires_npm = false, -- if stand-alone parser without npm dependencies
        requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
      },
      maintainers = { '@blaiselcq' },
    }
    return opts
  end,
}
