---@alias User.SnacksImage.Mode 'float'|'inline'|'hidden'

---@class User.SnacksImage.Controller
---@field buf integer
---@field mode User.SnacksImage.Mode
---@field group integer
---@field inline? snacks.image.inline

---@type table<integer, User.SnacksImage.Controller>
local controllers = {}

local function close_hover()
  Snacks.image.doc.hover_close()
  pcall(vim.api.nvim_del_augroup_by_name, 'snacks.image.hover')
end

---@param controller User.SnacksImage.Controller
local function clear_inline(controller)
  if not controller.inline then
    return
  end

  vim.iter(controller.inline.imgs):each(function(image) image:close() end)
  controller.inline.imgs = {}
  controller.inline.idx = {}
end

---@param controller User.SnacksImage.Controller
local function update_float(controller)
  if controller.mode == 'float' and controller.buf == vim.api.nvim_get_current_buf() then
    vim.schedule(Snacks.image.hover)
  end
end

---@param buf integer
---@return User.SnacksImage.Controller
local function get_controller(buf)
  if controllers[buf] then
    return controllers[buf]
  end

  -- Replace Snacks' attach-once document handler so the mode can change without reopening the buffer.
  pcall(vim.api.nvim_del_augroup_by_name, 'snacks.image.doc.' .. buf)
  local controller = {
    buf = buf,
    mode = 'float',
    group = vim.api.nvim_create_augroup('user.snacks.image.' .. buf, { clear = true }),
  }
  controllers[buf] = controller

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'CursorMoved' }, {
    group = controller.group,
    buffer = buf,
    callback = function() update_float(controller) end,
  })
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = controller.group,
    buffer = buf,
    once = true,
    callback = function()
      clear_inline(controller)
      controllers[buf] = nil
    end,
  })

  return controller
end

---@param controller User.SnacksImage.Controller
local function ensure_inline(controller)
  if controller.inline then
    return
  end

  local update = Snacks.image.inline.update
  controller.inline = Snacks.image.inline.new(controller.buf)
  controller.inline.update = function(self)
    if controller.mode == 'inline' then
      update(self)
    end
  end
end

---@param controller User.SnacksImage.Controller
---@param mode User.SnacksImage.Mode
local function set_mode(controller, mode)
  close_hover()
  clear_inline(controller)
  Snacks.image.placement.clean(controller.buf)
  controller.mode = mode

  if mode == 'inline' then
    ensure_inline(controller)
    controller.inline:update()
  elseif mode == 'float' then
    update_float(controller)
  end

  vim.notify('Image rendering: ' .. mode, vim.log.levels.INFO, { title = 'Snacks Image' })
end

local function cycle_rendering()
  local controller = get_controller(vim.api.nvim_get_current_buf())
  local modes = Snacks.image.terminal.env().placeholders and { 'float', 'inline', 'hidden' } or { 'float', 'hidden' }
  local index = vim.iter(modes):enumerate():filter(function(_, mode) return mode == controller.mode end):next() or 1
  set_mode(controller, modes[index % #modes + 1])
end

---@param src? string
local function open_full_image(src)
  if not src then
    vim.notify('No image, math expression, or diagram under cursor', vim.log.levels.WARN, { title = 'Snacks Image' })
    return
  end

  close_hover()
  vim.cmd('tabnew')
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].filetype = 'image'
  vim.bo[buf].swapfile = false
  vim.keymap.set('n', 'q', '<cmd>tabclose<cr>', { buffer = buf, desc = 'Close image' })
  vim.keymap.set('n', '<esc>', '<cmd>tabclose<cr>', { buffer = buf, desc = 'Close image' })
  Snacks.image.placement.new(buf, src, { auto_resize = true, conceal = true })
end

local function show_full_image() Snacks.image.doc.at_cursor(open_full_image) end

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>i', group = 'image' },
      },
    },
  },
  {
    'snacks.nvim',
    keys = {
      { '<leader>ip', cycle_rendering, ft = 'markdown', repeatable = true, desc = 'Image cycle preview' },
      { '<leader>if', show_full_image, ft = 'markdown', repeatable = true, desc = 'Image Full preview' },
    },
    opts = {
      image = {
        enabled = not vim.env.INSIDE_DOCKER,
        doc = {
          inline = false,
          float = true,
        },
      },
      styles = {
        snacks_image = {
          border = 'none',
          relative = 'cursor',
          col = 1,
          row = 1,
        },
      },
    },
  },
}
