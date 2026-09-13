---@class MiniAiWhichKey.Object
---@field [1] string
---@field desc string

local native_line_mappings = {
  around_last = '',
  inside_last = '',
}

if vim.g.distribution == 'lazyvim' then
  return {
    'nvim-mini/mini.ai',
    opts = { mappings = native_line_mappings },
  }
end

-- taken from MiniExtra.gen_ai_spec.buffer
local function ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line('$')
  if ai_type == 'i' then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

-- register all text objects with which-key
local function ai_whichkey(opts)
  ---@type MiniAiWhichKey.Object[]
  local objects = {
    { ' ', desc = 'whitespace' },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { '(', desc = '() block' },
    { ')', desc = '() block with ws' },
    { '<', desc = '<> block' },
    { '>', desc = '<> block with ws' },
    { '?', desc = 'user prompt' },
    { 'U', desc = 'use/call without dot' },
    { '[', desc = '[] block' },
    { ']', desc = '[] block with ws' },
    { '_', desc = 'underscore' },
    { '`', desc = '` string' },
    { 'a', desc = 'argument' },
    { 'b', desc = ')]} block' },
    { 'c', desc = 'class' },
    { 'd', desc = 'digit(s)' },
    { 'e', desc = 'CamelCase / snake_case' },
    { 'f', desc = 'function' },
    { 'g', desc = 'entire file' },
    { 'i', desc = 'indent' },
    { 'o', desc = 'block, conditional, loop' },
    { 'q', desc = 'quote `"\'' },
    { 't', desc = 'tag' },
    { 'u', desc = 'use/call' },
    { '{', desc = '{} block' },
    { '}', desc = '{} with ws' },
  }

  ---@type wk.Spec[]
  local ret = { mode = { 'o', 'x' } }
  ---@type table<string, string>
  local mappings = vim.tbl_extend('force', {}, {
    around = 'a',
    inside = 'i',
    around_next = 'an',
    inside_next = 'in',
    around_last = 'al',
    inside_last = 'il',
  }, opts.mappings or {})
  mappings.goto_left = nil
  mappings.goto_right = nil

  ---Append which key specs for every text object.
  ---@param prefix string
  ---@param specs wk.Spec[]
  ---@param textobjects MiniAiWhichKey.Object[]
  ---@return wk.Spec[]
  local function append_textobject_specs(prefix, specs, textobjects)
    return vim
      .iter(textobjects)
      :map(function(object)
        local desc = object.desc
        if prefix:sub(1, 1) == 'i' then
          desc = desc:gsub(' with ws', '')
        end
        return { prefix .. object[1], desc = desc }
      end)
      :fold(specs, function(result, spec)
        result[#result + 1] = spec
        return result
      end)
  end

  ret = vim.iter(mappings):filter(function(_, prefix) return prefix ~= '' end):fold(ret, function(specs, name, prefix)
    local group_name = name:gsub('^around_', ''):gsub('^inside_', '')
    specs[#specs + 1] = { prefix, group = group_name }
    return append_textobject_specs(prefix, specs, objects)
  end)

  require('which-key').add(ret, { notify = false })
end

return {
  'nvim-mini/mini.ai',
  event = function() return { 'User LazyBufEnter' } end,
  opts = function()
    local ai = require('mini.ai')
    return {
      n_lines = 500,
      mappings = native_line_mappings,
      custom_textobjects = {
        o = ai.gen_spec.treesitter({ -- code block
          a = { '@block.outer', '@conditional.outer', '@loop.outer' },
          i = { '@block.inner', '@conditional.inner', '@loop.inner' },
        }),
        f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }), -- function
        c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }), -- class
        t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
        d = { '%f[%d]%d+' }, -- digits
        e = { -- Word with case
          { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
          '^().*()$',
        },
        g = ai_buffer, -- buffer
        u = ai.gen_spec.function_call(), -- u for "Usage"
        U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }), -- without dot in function name
      },
    }
  end,
  config = function(_, opts)
    require('mini.ai').setup(opts)
    local ok, _ = pcall(require, 'which-key')
    if ok then
      ai_whichkey(opts)
    end
  end,
}
