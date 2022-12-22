local hop = require('hop')
hop.setup {
  perm_method = require('hop.perm').TrieBacktrackFilling,
  reverse_distribution = false,
  case_insensitive = true,
  term_seq_bias = 3 / 4,
  winblend = 50,
  teasing = true
}
