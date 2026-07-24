-- Enable OSC 52 inside docker
if vim.env.INSIDE_DOCKER then
  local cache = {
    ['+'] = { {}, 'v' },
    ['*'] = { {}, 'v' },
  }

  local function copy(reg)
    local osc52_copy = require('vim.ui.clipboard.osc52').copy(reg)

    return function(lines, regtype)
      cache[reg] = { vim.deepcopy(lines), regtype }
      osc52_copy(lines)
    end
  end

  local function paste(reg)
    return function() return vim.deepcopy(cache[reg]) end
  end

  vim.g.clipboard = {
    name = 'OSC 52 (copy only)',
    copy = {
      ['+'] = copy('+'),
      ['*'] = copy('*'),
    },
    paste = {
      ['+'] = paste('+'),
      ['*'] = paste('*'),
    },
  }
end
