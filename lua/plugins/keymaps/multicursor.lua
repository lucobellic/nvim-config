---@type fun()
local function next_cursor() vim.cmd.normal({ vim.v.count1 .. ']C', bang = true }) end

---@type fun()
local function previous_cursor() vim.cmd.normal({ vim.v.count1 .. '[C', bang = true }) end

---@type RepeatableOpt
local repeatable = { [';'] = next_cursor, [','] = previous_cursor }

return {
  'folke/which-key.nvim',
  opts = {
    spec = {
      { '<leader>m', group = 'multicursor', mode = { 'n', 'x' } },
    },
  },
  keys = {
    { '<leader>ms', '1Q', mode = { 'n', 'x' }, desc = 'Multicursor at search matches' },
    { '<leader>mc', 'Q', desc = 'Multicursor toggle current position' },
    { '<leader>mf', 'q=', desc = 'Multicursor toggle follow mode' },
    { '<leader>mr', 'gQ', desc = 'Multicursor restore multicursors' },
    {
      '<leader>m;',
      next_cursor,
      repeatable = repeatable,
      desc = 'Multicursor next cursor',
    },
    {
      '<leader>m,',
      previous_cursor,
      repeatable = repeatable,
      desc = 'Multicursor previous cursor',
    },
  },
}
