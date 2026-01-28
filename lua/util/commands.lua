local M = {}

---Convert string valid command name with title case
---@param str string
---@return string
local function command_title_case(str)
  -- Replace special character with spaces and convert to title case
  ---@diagnostic disable-next-line
  return str
    :gsub('%W', ' ')
    :gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
    :gsub('%s+', '')
end

---Create user command from keymap
---@param command_name string
---@param keymap table<string, any>
local function create_command_from_keymap(command_name, keymap)
  local cmd = vim.api.nvim_replace_termcodes(keymap.lhs, true, false, true)
  vim.api.nvim_create_user_command(
    command_name,
    function() vim.api.nvim_feedkeys(cmd, 't', true) end,
    { desc = keymap.desc }
  )
end

---Create command from keymaps
---Iterate over all keymaps and create command for description
---only if command does not already exist
function M.create_command_from_keymaps()
  local keymaps = vim.api.nvim_get_keymap('n')
  local keymaps_with_desc = vim.tbl_filter(function(keymap) return keymap.desc ~= nil end, keymaps)
  for _, keymap in ipairs(keymaps_with_desc or {}) do
    local command_name = command_title_case(keymap.desc)
    if vim.fn.exists(':' .. command_name) == 0 then
      create_command_from_keymap(command_name, keymap)
    end
  end
end

--- Create autocommand to track recently visited files
--- Update the global variable `vim.g.visited_files`
function M.track_visited_files()
  vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('snacks_recent_files', { clear = true }),
    callback = function(args)
      local file = args.file
      if file == '' or vim.bo[args.buf].buftype ~= '' then
        return
      end

      file = vim.fs.normalize(vim.fn.fnamemodify(file, ':p'), { _fast = true, expand_env = false })

      --- Clear entry to be re-added at the front
      local visited_files = vim.g.VISITEDFILES or {}
      if vim.tbl_contains(visited_files, file) then
        visited_files = vim.tbl_filter(function(f) return f ~= file end, visited_files)
      end
      table.insert(visited_files, 1, file)

      if #visited_files > 100 then
        visited_files[101] = nil
      end

      vim.g.VISITEDFILES = visited_files
    end,
  })
end

function M.create_block_spinner_command()
  vim.api.nvim_create_user_command('BlockSpinner', function(opts)
    local BlockSpinner = require('plugins.codecompanion.utils.block_spinner')
    local bufnr = vim.api.nvim_get_current_buf()
    local ns_id = vim.api.nvim_create_namespace('block_spinner')

    local start_line, end_line
    if opts.range == 2 then
      start_line = opts.line1
      end_line = opts.line2
    else
      vim.notify('BlockSpinner requires a visual selection', vim.log.levels.WARN)
      return
    end

    local spinner = BlockSpinner.new({
      bufnr = bufnr,
      ns_id = ns_id,
      start_line = start_line,
      end_line = end_line,
    })

    spinner:start()

    vim.defer_fn(function() spinner:stop() end, 5000)
  end, {
    range = true,
    desc = 'Show block spinner on visual selection',
  })
end

---Setup window resize utility
---Resizes windows to minimum dimensions when entering them
---@param opts {min_width?: number, min_height?: number, ignore_buftypes?: string[], ignore_filetypes?: string[]}
function M.setup_window_resize(opts)
  opts = opts or {}
  local min_width = opts.min_width or 80
  local min_height = opts.min_height or 20
  local ignore_buftypes = opts.ignore_buftypes or {}
  local ignore_filetypes = opts.ignore_filetypes or {}
  local group_name = 'window_resize'

  local enabled = true
  local augroup = vim.api.nvim_create_augroup(group_name, { clear = true })

  vim.api.nvim_create_user_command('ToggleFocusResize', function() enabled = not enabled end, {
    desc = 'Toggle Focus Resize',
  })

  vim.api.nvim_create_autocmd('WinEnter', {
    group = augroup,
    ---@param args vim.api.keyset.create_autocmd.callback_args
    callback = function(args)
      if not enabled then
        return
      end
      local winid = vim.api.nvim_get_current_win()
      local buftype = vim.bo[args.buf].buftype
      local filetype = vim.bo[args.buf].filetype

      local disabled = vim.b.focus_disable
        or not vim.api.nvim_win_is_valid(winid)
        or vim.tbl_contains(ignore_buftypes, buftype)
        or vim.tbl_contains(ignore_filetypes, filetype)

      if not disabled then
        local current_width = vim.api.nvim_win_get_width(winid)
        local current_height = vim.api.nvim_win_get_height(winid)
        local change_width = current_width < min_width
        local change_height = current_height < min_height

        if change_width then
          vim.api.nvim_win_set_width(winid, math.max(current_width, min_width))
        end
        if change_height then
          vim.api.nvim_win_set_height(winid, math.max(current_height, min_height))
        end
      end
    end,
    desc = 'Resize window to minimum dimensions on enter',
  })
end

return M
