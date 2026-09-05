---@class UndoKeep.Snapshot
---@field path string
---@field lines string[]
---@field undo string
---@field sequence integer

---@class UndoKeep
local M = {}

local directory = vim.fn.stdpath('state') .. '/undo-keep'

---@return string
local function temporary_path() return directory .. '/' .. vim.fn.sha256(vim.fn.tempname()) .. '.tmp' end

---@param path string
---@return string
local function read_bytes(path)
  local file = assert(io.open(path, 'rb'))
  local contents = file:read('*a')
  file:close()
  return contents
end

---@param path string
---@param contents string
local function write_bytes(path, contents)
  local file = assert(io.open(path, 'wb'))
  local success, message = file:write(contents)
  local closed, close_message = file:close()
  assert(success, message)
  assert(closed, close_message)
  assert(vim.uv.fs_chmod(path, 384)) -- 0600
end

---@param buffer integer
---@return boolean
local function eligible(buffer)
  return vim.bo[buffer].buftype == ''
    and vim.bo[buffer].undofile
    and not vim.bo[buffer].binary
    and vim.bo[buffer].undolevels ~= -1
    and not (vim.bo[buffer].undolevels == -123456 and vim.go.undolevels == -1)
    and vim.api.nvim_buf_get_name(buffer) ~= ''
end

---@param buffer integer
---@return string
local function snapshot_path(buffer)
  return directory .. '/' .. vim.fn.sha256(vim.api.nvim_buf_get_name(buffer)) .. '.mpack'
end

---@param buffer integer
local function save(buffer)
  if not eligible(buffer) or vim.bo[buffer].modified then
    return
  end
  local temporary = temporary_path()
  local success, message = pcall(function()
    vim.api.nvim_buf_call(buffer, function()
      if #vim.fn.undotree().entries == 0 then
        return -- :wundo does not create a file for an empty tree.
      end
      vim.cmd('silent wundo! ' .. vim.fn.fnameescape(temporary))
      ---@type UndoKeep.Snapshot
      local snapshot = {
        path = vim.api.nvim_buf_get_name(buffer),
        lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false),
        undo = read_bytes(temporary),
        sequence = vim.fn.undotree().seq_last,
      }
      write_bytes(temporary, vim.mpack.encode(snapshot))
      assert(vim.uv.fs_rename(temporary, snapshot_path(buffer)))
    end)
  end)
  vim.fn.delete(temporary)
  if not success then
    vim.notify('undo-keep: could not save history: ' .. tostring(message), vim.log.levels.WARN)
  end
end

---Validate cached content and undo together without touching the user's buffer.
---@param snapshot UndoKeep.Snapshot
---@param undo_path string
local function validate(snapshot, undo_path)
  local scratch = vim.api.nvim_create_buf(false, true)
  local success, message = pcall(function()
    vim.api.nvim_buf_call(scratch, function()
      vim.bo.undolevels = -1
      vim.api.nvim_buf_set_lines(scratch, 0, -1, false, snapshot.lines)
      vim.bo.undolevels = vim.go.undolevels
      vim.cmd('silent rundo ' .. vim.fn.fnameescape(undo_path))
      assert(vim.fn.undotree().seq_last == snapshot.sequence, 'undo snapshot could not be loaded')
    end)
  end)
  vim.api.nvim_buf_delete(scratch, { force = true })
  assert(success, message)
end

---@param buffer integer
local function restore(buffer)
  if not eligible(buffer) or vim.bo[buffer].modified or not vim.bo[buffer].modifiable then
    return
  end
  local path = snapshot_path(buffer)
  if vim.fn.filereadable(path) == 0 then
    return
  end
  local temporary = temporary_path()
  local success, message = pcall(function()
    vim.api.nvim_buf_call(buffer, function()
      -- Never replace an existing tree, including a native autoread reload.
      if vim.fn.undotree().seq_last > 0 then
        return
      end
      ---@type UndoKeep.Snapshot
      local snapshot = vim.mpack.decode(read_bytes(path))
      assert(snapshot.path == vim.api.nvim_buf_get_name(buffer), 'snapshot path mismatch')
      if snapshot.sequence == 0 then
        return -- No historical edits to recover.
      end
      local disk_lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
      write_bytes(temporary, snapshot.undo)
      validate(snapshot, temporary)
      if vim.deep_equal(snapshot.lines, disk_lines) then
        vim.cmd('silent rundo ' .. vim.fn.fnameescape(temporary))
        return
      end
      local view = vim.fn.winsaveview()
      local endofline = vim.bo[buffer].endofline
      local restored, restore_message = pcall(function()
        vim.api.nvim_buf_set_lines(buffer, 0, -1, false, snapshot.lines)
        vim.cmd('silent rundo ' .. vim.fn.fnameescape(temporary))
        assert(vim.fn.undotree().seq_last == snapshot.sequence, 'undo snapshot could not be loaded')
      end)
      -- Setting undolevels to itself closes the block without clearing history.
      vim.bo[buffer].undolevels = vim.bo[buffer].undolevels
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, disk_lines)
      vim.bo[buffer].endofline = endofline
      vim.bo[buffer].modified = false
      vim.fn.winrestview(view)
      assert(restored, restore_message)
    end)
  end)
  vim.fn.delete(temporary)
  if not success then
    vim.notify('undo-keep: could not restore history: ' .. tostring(message), vim.log.levels.WARN)
  end
end

---Recover persistent trees after offline changes, leaving native reload policy alone.
---@public
function M.setup()
  vim.fn.mkdir(directory, 'p', 448) -- 0700: snapshots contain full file contents.
  assert(vim.uv.fs_chmod(directory, 448))
  local group = vim.api.nvim_create_augroup('UndoKeep', { clear = true })
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = group,
    ---@param event vim.api.keyset.create_autocmd.callback_args
    callback = function(event) restore(event.buf) end,
  })
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufUnload' }, {
    group = group,
    ---@param event vim.api.keyset.create_autocmd.callback_args
    callback = function(event) save(event.buf) end,
  })
end

return M
