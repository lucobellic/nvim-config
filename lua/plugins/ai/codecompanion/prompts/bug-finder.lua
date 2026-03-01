return {
  diff_and_attach = function(args)
    local branch = '$(git merge-base HEAD origin/develop)...HEAD'
    local changes = 'changes.diff'
    vim.fn.system('git diff --unified=10000 ' .. branch .. ' > ' .. changes)

    --- @type CodeCompanion.Chat
    local chat = require('codecompanion').buf_get_chat(vim.api.nvim_get_current_buf())
    local path = vim.fn.getcwd() .. '/' .. changes
    local id = '<file>' .. changes .. '</file>'
    local lines = vim.fn.readfile(path)
    local content = table.concat(lines, '\n')

    chat:add_message({
      role = 'user',
      content = 'git diff content from ' .. path .. ':\n' .. content,
    }, { reference = id, visible = false })

    chat.context:add({
      id = id,
      path = path,
      source = '',
    })

    return ''
  end,
}
