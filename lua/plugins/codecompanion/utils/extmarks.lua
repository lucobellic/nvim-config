--- @class CodeCompanion.InlineExtmark
--- @field unique_line_sign_text string
--- @field first_line_sign_text string
--- @field last_line_sign_text string
--- @field extmark vim.api.keyset.set_extmark

local M = {}

--- @type CodeCompanion.InlineExtmark
local default_opts = {
  unique_line_sign_text = '',
  first_line_sign_text = '┌',
  last_line_sign_text = '└',
  extmark = {
    sign_hl_group = 'DiagnosticWarn',
    sign_text = '│',
    priority = 1000,
  },
}

--- @param opts CodeCompanion.InlineExtmark
--- @param data CodeCompanion.InlineArgs
--- @param ns_id number unique namespace id
local function create_extmarks(opts, data, ns_id)
  --- @type {bufnr: number, start_line: number, end_line: number}
  local context = data.context

  -- Handle the case where start and end lines are the same (unique line)
  if context.start_line == context.end_line then
    vim.api.nvim_buf_set_extmark(
      context.bufnr,
      ns_id,
      context.start_line - 1,
      0,
      vim.tbl_deep_extend('force', opts.extmark or {}, {
        sign_text = opts.unique_line_sign_text or opts.extmark.sign_text,
      })
    )
    return
  end

  -- Set extmark for the first line with special options
  vim.api.nvim_buf_set_extmark(
    context.bufnr,
    ns_id,
    context.start_line - 1,
    0,
    vim.tbl_deep_extend('force', opts.extmark or {}, {
      sign_text = opts.first_line_sign_text or opts.extmark.sign_text,
    })
  )

  -- Set extmarks for the middle lines with standard options
  for i = context.start_line + 1, context.end_line - 1 do
    vim.api.nvim_buf_set_extmark(context.bufnr, ns_id, i - 1, 0, opts.extmark)
  end

  -- Set extmark for the last line with special options
  if context.end_line > context.start_line then
    vim.api.nvim_buf_set_extmark(
      context.bufnr,
      ns_id,
      context.end_line - 1,
      0,
      vim.tbl_deep_extend('force', opts.extmark or {}, {
        sign_text = opts.last_line_sign_text or opts.extmark.sign_text,
      })
    )
  end
end

--- @param opts CodeCompanion.InlineExtmark
local function create_autocmds(opts)
  vim.api.nvim_create_autocmd({ 'User' }, {
    pattern = { 'CodeCompanionRequest*' },
    callback =
      --- @param args {buf: number, data : CodeCompanion.InlineArgs, match: string}
      function(args)
        local data = args.data or {}
        local context = data and data.context or {}
        if data and data.context then
          local ns_id = vim.api.nvim_create_namespace('CodeCompanionInline_' .. data.id)
          if args.match:find('StartedInline') then
            create_extmarks(opts, data, ns_id)
          elseif args.match:find('FinishedInline') then
            vim.api.nvim_buf_clear_namespace(context.bufnr, ns_id, 0, -1)
          end
        end
      end,
  })
end

--- @param opts? CodeCompanion.InlineExtmark
function M.setup(opts) create_autocmds(vim.tbl_deep_extend('force', default_opts, opts or {})) end

return M
