---@type integer
local ns_id = vim.api.nvim_create_namespace('dockerfile_from_separator')

---Add visual separators above FROM instructions in Dockerfiles
---@return nil
local function add_from_separators()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  local parser = vim.treesitter.get_parser(0, 'dockerfile')
  local tree = parser and parser:parse()[1]
  if not tree then
    return
  end

  local query = vim.treesitter.query.parse('dockerfile', [[ (from_instruction) @from ]])

  vim
    .iter(query:iter_captures(tree:root(), 0))
    :filter(function(id, node) return query.captures[id] == 'from' and node:range() > 0 end)
    :each(
      function(_, node)
        vim.api.nvim_buf_set_extmark(0, ns_id, node:range(), 0, {
          virt_lines = { { { string.rep('_', vim.api.nvim_win_get_width(0)), 'Comment' } } },
          virt_lines_above = true,
        })
      end
    )
end

local group = vim.api.nvim_create_augroup('DockerfileSeparator', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'WinResized' }, {
  group = group,
  buffer = 0,
  callback = add_from_separators,
})

add_from_separators()
