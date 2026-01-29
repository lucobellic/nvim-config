local core = require('util.term.core')

-- Disable spell checking in terminal buffers
vim.opt_local.spell = false
vim.opt_local.foldcolumn = '0'
vim.opt_local.signcolumn = 'no'
vim.opt_local.statuscolumn = ''
vim.opt_local.wrap = false

-- Disable animations from mini.animate
vim.b.miniindentscope_disable = true
vim.b.minianimate_disable = true

--- Define terminal keymaps
---@return table[] List of keymap definitions
local function get_keymaps()
  return {
    {
      mode = { 't', 'n' },
      lhs = '<C-q>',
      rhs = function()
        if core.active_term then
          core.remove(core.active_term.name)
        end
      end,
      opts = { buffer = true, silent = true, desc = 'Term Close' },
    },
    {
      mode = { 'n' },
      lhs = '<Esc>',
      rhs = function() core.hide() end,
      opts = { buffer = true, silent = true, desc = 'Term Close' },
    },
    {
      mode = { 't', 'n' },
      lhs = '<C-t>',
      rhs = function() core.new() end,
      opts = { buffer = true, silent = true, desc = 'Term New' },
    },
    {
      mode = { 't', 'n' },
      lhs = '<C-r>',
      rhs = function() core.replace() end,
      opts = { buffer = true, silent = true, desc = 'Term Replace' },
    },
    {
      mode = { 't', 'n' },
      lhs = '<C-h>',
      rhs = function() core.prev() end,
      opts = { buffer = true, silent = true, desc = 'Term Previous' },
    },
    {
      mode = { 't', 'n' },
      lhs = '<C-l>',
      rhs = function() core.next() end,
      opts = { buffer = true, silent = true, desc = 'Term Next' },
    },
    {
      mode = { 't', 'n' },
      lhs = '<C-Up>',
      rhs = function() core.increase_size() end,
      opts = { buffer = true, silent = true, desc = 'Term Increase Size' },
    },
    {
      mode = { 't', 'n' },
      lhs = '<C-Down>',
      rhs = function() core.decrease_size() end,
      opts = { buffer = true, silent = true, desc = 'Term Decrease Size' },
    },
    {
      mode = 't',
      lhs = '<F7>',
      rhs = function() core.toggle() end,
      opts = { buffer = true, silent = true, desc = 'Toggle Terminal' },
    },
    {
      mode = 'n',
      lhs = 'q',
      rhs = function() core.toggle() end,
      opts = { buffer = true, silent = true, desc = 'Toggle Terminal' },
    },
    {
      mode = 'n',
      lhs = 'gf',
      rhs = function() require('util.util').open_file() end,
      opts = { buffer = true },
    },
  }
end

--- Save existing buffer-local keymaps that will be overwritten
---@param keymaps table[] List of keymap definitions to check
---@return table[] saved_keymaps List of saved keymaps
local function save_existing_keymaps(keymaps)
  local saved_keymaps = {}

  vim.iter(keymaps):each(function(keymap)
    local modes = type(keymap.mode) == 'table' and keymap.mode or { keymap.mode }

    vim.iter(modes):each(function(mode)
      -- Get existing keymap for this mode and lhs
      local existing = vim.fn.maparg(keymap.lhs, mode, false, true)

      -- Only save if there's an existing buffer-local keymap
      if existing and existing ~= vim.empty_dict() and existing.buffer == 1 then
        table.insert(saved_keymaps, {
          mode = mode,
          lhs = keymap.lhs,
          rhs = existing.rhs or existing.callback,
          opts = {
            buffer = true,
            silent = existing.silent == 1,
            noremap = existing.noremap == 1,
            expr = existing.expr == 1,
            nowait = existing.nowait == 1,
            desc = existing.desc,
          },
        })
      end
    end)
  end)

  return saved_keymaps
end

--- Apply keymaps to the current buffer
---@param keymaps table[] List of keymap definitions to apply
local function apply_keymaps(keymaps)
  vim.iter(keymaps):each(function(keymap) vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts) end)
end

--- Setup terminal keymaps with backup of existing ones
local function setup_keymaps()
  local keymaps = get_keymaps()
  local saved_keymaps = save_existing_keymaps(keymaps)

  apply_keymaps(keymaps)

  -- Store keymaps and saved mappings in buffer variable for later restoration
  vim.b.term_ftplugin_keymaps = keymaps
  vim.b.term_ftplugin_saved_keymaps = saved_keymaps
end

-- Initialize keymaps
setup_keymaps()
