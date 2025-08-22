require('config.start')

require('config.docker_clipboard')
require('config.profiling')
require('config.keymap_override')
require('config.lsp')
require('config.shell')
require('config.lazy')
require('config.diagnostic')
require('config.filetype')
require('config.neovide')

if not vim.g.started_by_firenvim then
  require('util.work.overseer')
end

if vim.g.distribution ~= 'lazyvim' then
  require('config.options')
  require('config.autocmds')
end
