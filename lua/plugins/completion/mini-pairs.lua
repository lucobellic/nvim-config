-- Disable mini.pairs
return {
  'echasnovski/mini.pairs',
  enabled = false,
  opts = {
    mappings = {
      ['<'] = { action = 'open', pair = '<>', neigh_pattern = '\r.', register = { cr = false } },
      ['>'] = { action = 'close', pair = '<>', register = { cr = false } },
    },
  },
}
