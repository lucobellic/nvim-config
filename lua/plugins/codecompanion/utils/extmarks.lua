--- @class CodeCompanion.InlineExtmark
--- @field unique_line_sign_text string Text used for sign when there's only a single line
--- @field first_line_sign_text string Text used for sign on the first line of multi-line section
--- @field last_line_sign_text string Text used for sign on the last line of multi-line section
--- @field extmark vim.api.keyset.set_extmark Extmark options passed to nvim_buf_set_extmark

local M = {}

local hl_group = 'DiagnosticVirtualTextWarn'
local priority = 2048
local repeat_interval = 100

--- @type CodeCompanion.InlineExtmark
local default_opts = {
  unique_line_sign_text = '',
  first_line_sign_text = '┌',
  last_line_sign_text = '└',
  extmark = {
    sign_hl_group = hl_group,
    sign_text = '│',
    priority = priority,
  },
}

--- @type VirtualTextBlockSpinner.SpinnerOpts
--- @diagnostic disable-next-line: missing-fields
local virtual_text_spinners_opts = {
  hl_group = 'Comment',
  repeat_interval = repeat_interval,
  extmark = {
    virt_text_pos = 'overlay',
    priority = priority,
  },
}

--- @type {number: [VirtualTextSpinner, VirtualTextBlockSpinner]}
local virtual_text_spinners = {}

--- Helper function to set a line extmark with specified sign text
--- @param bufnr number
--- @param ns_id number
--- @param line_num number Line number
--- @param opts CodeCompanion.InlineExtmark Extmark options
--- @param sign_type string Key in opts for the sign text to use
local function set_line_extmark(bufnr, ns_id, line_num, opts, sign_type)
  vim.api.nvim_buf_set_extmark(
    bufnr,
    ns_id,
    line_num - 1, -- Convert to 0-based index
    0,
    vim.tbl_deep_extend('force', opts.extmark or {}, {
      sign_text = opts[sign_type] or opts.extmark.sign_text,
    })
  )
end

--- Start animated spinners for a buffer region
--- This function creates and starts two spinner objects:
---  - A block spinner that spans multiple lines
---  - A centered spinner that appears in the middle of the block
---
--- @param bufnr number Buffer number where the spinners will be displayed
--- @param ns_id number Namespace ID for the extmarks
--- @param start_line number Starting line of the region (0-indexed)
--- @param end_line number Ending line of the region (0-indexed)
local function start_spinners(bufnr, ns_id, start_line, end_line)
  local block_spinner = require('plugins.codecompanion.utils.block_spinner').new({
    bufnr = bufnr,
    ns_id = ns_id,
    start_line = start_line,
    end_line = end_line,
    opts = virtual_text_spinners_opts,
  })

  local spinner = require('plugins.codecompanion.utils.spinner').new({
    bufnr = bufnr,
    ns_id = ns_id,
    line_num = start_line + math.floor((end_line - start_line) / 2),
    width = block_spinner.width,
    opts = {
      repeat_interval = repeat_interval,
      extmark = { virt_text_pos = 'overlay', priority = priority + 1 },
    },
  })

  spinner:start()
  block_spinner:start()
  virtual_text_spinners[ns_id] = { spinner, block_spinner }
end

--- Stop active spinners associated with a namespace ID
--- @param ns_id number The namespace ID to stop spinners
local function stop_spinner(ns_id)
  local block_spinner, spinner = unpack(virtual_text_spinners[ns_id])
  if spinner then
    spinner:stop()
  end
  if block_spinner then
    block_spinner:stop()
  end
  virtual_text_spinners[ns_id] = nil
end

--- Creates extmarks for inline code annotations
--- @param opts CodeCompanion.InlineExtmark Configuration options for the extmarks
--- @param data CodeCompanion.InlineArgs Data containing context information about the code block
--- @param ns_id number unique namespace id for the extmarks
local function create_extmarks(opts, data, ns_id)
  --- @type {bufnr: number, start_line: number, end_line: number}
  local context = data.context

  -- Start a spinner on first line at the end of line
  start_spinners(context.bufnr, ns_id, context.start_line, context.end_line)

  -- Handle the case where start and end lines are the same (unique line)
  if context.start_line == context.end_line then
    set_line_extmark(context.bufnr, ns_id, context.start_line, opts, 'unique_line_sign_text')
    return
  end

  -- Set extmark for the first line with special options
  set_line_extmark(context.bufnr, ns_id, context.start_line, opts, 'first_line_sign_text')

  -- Set extmarks for the middle lines with standard options
  for i = context.start_line + 1, context.end_line - 1 do
    vim.api.nvim_buf_set_extmark(context.bufnr, ns_id, i - 1, 0, opts.extmark)
  end

  -- Set extmark for the last line with special options
  if context.end_line > context.start_line then
    set_line_extmark(context.bufnr, ns_id, context.end_line, opts, 'last_line_sign_text')
  end
end

--- Creates autocmds for CodeCompanionRequest events
--- @param opts CodeCompanion.InlineExtmark Configuration options passed from setup
local function create_autocmds(opts)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'CodeCompanionRequest*',
    callback = function(args)
      local data = args.data or {}
      local context = data.context or {}

      if vim.tbl_isempty(context) then
        return
      end

      local ns_id = vim.api.nvim_create_namespace('CodeCompanionInline_' .. data.id)

      if args.match:find('StartedInline') then
        create_extmarks(opts, data, ns_id)
      elseif args.match:find('FinishedInline') then
        stop_spinner(ns_id)
        vim.api.nvim_buf_clear_namespace(context.bufnr, ns_id, 0, -1)
      end
    end,
  })
end

--- @param opts? CodeCompanion.InlineExtmark Optional configuration to override defaults
function M.setup(opts) create_autocmds(vim.tbl_deep_extend('force', default_opts, opts or {})) end

return M
