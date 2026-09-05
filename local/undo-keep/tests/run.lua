-- Run with isolated XDG_STATE_HOME and XDG_DATA_HOME; see README.md.
local plugin = vim.fn.getcwd() .. '/local/undo-keep'
vim.opt.runtimepath:prepend(plugin)
vim.opt.undofile = true
vim.opt.autoread = true
vim.opt.swapfile = false
vim.opt.undodir = vim.fn.stdpath('state') .. '/undo'
vim.fn.mkdir(vim.o.undodir, 'p')
require('undo-keep').setup()
assert(vim.o.undoreload == 10000, 'setup must preserve the native reload limit')

local directory = vim.fn.stdpath('state') .. '/fixtures'
vim.fn.mkdir(directory, 'p')

---@param expected string[]
local function expect_lines(expected)
  assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), expected), 'unexpected buffer content')
end

---@param lines string[]
local function change(lines)
  vim.bo.undolevels = vim.bo.undolevels
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.undolevels = vim.bo.undolevels
end

---@param name string
---@return string
local function fixture(name)
  vim.cmd('enew!')
  local path = directory .. '/' .. name
  vim.fn.writefile({ 'original' }, path)
  vim.cmd.edit(path)
  change({ 'saved' })
  vim.cmd.write()
  return path
end

local path = fixture('offline.txt')
vim.cmd('bwipeout!')
vim.fn.writefile({ 'external', 'new line' }, path)
vim.cmd.edit(path)
expect_lines({ 'external', 'new line' })
assert(not vim.bo.modified)
vim.cmd.undo()
expect_lines({ 'saved' })
assert(vim.bo.modified, 'undoing external changes must mark the buffer modified')
vim.cmd.undo()
expect_lines({ 'original' })
vim.cmd.redo()
vim.cmd.redo()
expect_lines({ 'external', 'new line' })

path = fixture('live.txt')
vim.fn.writefile({ 'external live', 'new line' }, path)
vim.cmd.checktime()
expect_lines({ 'external live', 'new line' })
assert(not vim.bo.modified)
vim.cmd.undo()
expect_lines({ 'saved' })
vim.cmd.undo()
expect_lines({ 'original' })

path = fixture('large.txt')
local lines = vim.fn['repeat']({ 'large file' }, 10001)
change(lines)
vim.cmd.write()
vim.fn.writefile({ 'external large' }, path)
vim.cmd.checktime()
expect_lines({ 'external large' })
assert(#vim.fn.undotree().entries == 0, 'large-file reload must respect the native undo limit')
vim.cmd.undo()
expect_lines({ 'external large' })

path = fixture('dirty.txt')
change({ 'unsaved local edit' })
vim.fn.writefile({ 'external dirty', 'extra line' }, path)
local conflict = vim.api.nvim_create_autocmd('FileChangedShell', {
  callback = function()
    vim.v.fcs_choice = '' -- Simulate choosing to keep local edits.
  end,
})
vim.cmd.checktime()
vim.api.nvim_del_autocmd(conflict)
expect_lines({ 'unsaved local edit' })
assert(vim.bo.modified)
vim.cmd.undo()
expect_lines({ 'saved' })

path = fixture('explicit-reload.txt')
vim.fn.writefile({ 'explicit reload', 'extra line' }, path)
vim.cmd('edit!')
expect_lines({ 'explicit reload', 'extra line' })
vim.cmd.undo()
expect_lines({ 'saved' })
vim.cmd.undo()
expect_lines({ 'original' })

path = fixture('branches.txt')
change({ 'branch one' })
local branch_sequence = vim.fn.undotree().seq_cur
vim.cmd.undo()
change({ 'branch two' })
vim.cmd.write()
vim.cmd('bwipeout!')
vim.fn.writefile({ 'external branch' }, path)
vim.cmd.edit(path)
expect_lines({ 'external branch' })
vim.cmd('undo ' .. branch_sequence)
expect_lines({ 'branch one' })

path = fixture('unchanged.txt')
vim.cmd('bwipeout!')
vim.cmd.edit(path)
expect_lines({ 'saved' })
vim.cmd.undo()
expect_lines({ 'original' })

path = fixture('corrupt.txt')
vim.cmd('bwipeout!')
local snapshot_path = vim.fn.stdpath('state') .. '/undo-keep/' .. vim.fn.sha256(path) .. '.mpack'
local file = assert(io.open(snapshot_path, 'rb'))
local snapshot = vim.mpack.decode(file:read('*a'))
file:close()
snapshot.lines = { 'incorrect cached content' }
file = assert(io.open(snapshot_path, 'wb'))
file:write(vim.mpack.encode(snapshot))
file:close()
vim.fn.writefile({ 'external corrupt' }, path)
local notify = vim.notify
local warned = false
---@param message string
vim.notify = function(message) warned = message:match('could not restore history') ~= nil end
vim.cmd.edit(path)
vim.notify = notify
expect_lines({ 'external corrupt' })
assert(not vim.bo.modified)
assert(vim.fn.undotree().seq_last == 0, 'corrupt snapshot must not change the undo tree')
assert(warned, 'corrupt snapshot should produce a warning')

path = fixture('disabled.txt')
vim.bo.undofile = false
change({ 'not persisted' })
vim.cmd.write()
local file = assert(io.open(vim.fn.stdpath('state') .. '/undo-keep/' .. vim.fn.sha256(path) .. '.mpack', 'rb'))
local persisted = vim.mpack.decode(file:read('*a'))
file:close()
assert(vim.deep_equal(persisted.lines, { 'saved' }), 'noundofile must prevent new snapshots')
vim.api.nvim_exec_autocmds('BufReadPost', { buffer = 0 })
expect_lines({ 'not persisted' })
vim.cmd('bwipeout!')

-- Verify persistence in genuinely separate Neovim processes.
local process_path = directory .. '/process.txt'
local setup = string.format(
  'vim.opt.rtp:prepend(%q); vim.opt.undofile = true; vim.opt.undodir = %q; require("undo-keep").setup()',
  plugin,
  vim.o.undodir
)
---@param commands string[]
local function run_process(commands)
  local arguments = { vim.v.progpath, '--clean', '--headless', '-c', 'lua ' .. setup }
  vim.iter(commands):each(function(command) vim.list_extend(arguments, { '-c', command }) end)
  local result = vim.system(arguments, { text = true }):wait(10000)
  assert(result.code == 0, result.stderr)
end
vim.fn.writefile({ 'original process' }, process_path)
run_process({
  'edit ' .. process_path,
  'lua vim.api.nvim_buf_set_lines(0, 0, -1, false, { "saved process" })',
  'write',
  'qa!',
})
vim.fn.writefile({ 'external process' }, process_path)
run_process({
  'edit ' .. process_path,
  'undo',
  'lua if vim.api.nvim_get_current_line() ~= "saved process" then vim.cmd("cquit") end',
  'undo',
  'lua if vim.api.nvim_get_current_line() ~= "original process" then vim.cmd("cquit") end',
  'qa!',
})

-- Let Neovim return to its idle event loop: no :checktime or custom watcher.
run_process({
  'edit ' .. process_path,
  'lua vim.api.nvim_buf_set_lines(0, 0, -1, false, { "before watcher" })',
  'write',
  string.format(
    [[lua vim.defer_fn(function()
      vim.fn.writefile({ 'native watcher', 'extra line' }, %q .. '.replacement')
      assert(vim.uv.fs_rename(%q .. '.replacement', %q))
      vim.defer_fn(function()
        if vim.api.nvim_get_current_line() ~= 'native watcher' then vim.cmd('cquit') end
        vim.cmd('undo')
        if vim.api.nvim_get_current_line() ~= 'before watcher' then vim.cmd('cquit') end
        vim.cmd('qa!')
      end, 1500)
    end, 200)]],
    process_path,
    process_path,
    process_path
  ),
})

print('undo-keep: all tests passed')
vim.cmd('qa!')
