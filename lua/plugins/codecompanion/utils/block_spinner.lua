--- @class VirtualTextBlockSpinner.Opts
--- @field hl_group string Highlight group for the spinner
--- @field repeat_interval number Interval in milliseconds to update the spinner
--- @field extmark vim.api.keyset.set_extmark Extmark options passed to nvim_buf_set_extmark
local spinner_opts = {
  hl_group = 'Comment',
  repeat_interval = 250,
  extmark = {
    virt_text_pos = 'inline',
    priority = 1000,
    virt_text_repeat_linebreak = true,
  },
}

--- @class VirtualTextBlockSpinner
--- @field bufnr number Buffer number where the text block spinner is shown
--- @field ns_id number The namespace ID for the extmark
--- @field start_line number Starting line (0-indexed) for the spinner
--- @field end_line number Ending line (0-indexed) for the spinner
--- @field ids table<number, number> Table of extmark IDs indexed by line numbers
--- @field first_line string First animation frame content
--- @field second_line string Second animation frame content
--- @field current_index number Current index in the spinner frames array
--- @field timer uv.uv_timer_t | nil Timer used to update spinner animation
--- @field opts VirtualTextBlockSpinner.Opts Configuration options for the spinner
local VirtualTextBlockSpinner = {
  bufnr = 0,
  ns_id = 0,
  start_line = 0,
  end_line = 0,
  ids = {},
  first_line = '',
  second_line = '',
  current_index = 1,
  timer = nil,
  opts = spinner_opts,
}

--- @class VirtualTextBlockSpinner.New
--- @field bufnr number Buffer number where the spinner will be shown
--- @field ns_id number Namespace ID for the extmarks
--- @field start_line number Starting line (1-indexed) for the spinner
--- @field end_line number Ending line (1-indexed) for the spinner
--- @field opts? VirtualTextBlockSpinner.Opts Optional configuration options

--- Creates a new VirtualTextBlockSpinner instance
--- @param opts VirtualTextBlockSpinner.New Options for the spinner
--- @return VirtualTextBlockSpinner self New spinner instance
function VirtualTextBlockSpinner.new(opts)
  local lines = vim.api.nvim_buf_get_lines(opts.bufnr, opts.start_line - 1, opts.end_line, false)
  local width = vim.fn.max(vim.iter(lines):map(function(line) return vim.fn.strdisplaywidth(line) end):totable()) / 2
  local first_line = string.rep('╲ ', width + 1)
  local second_line = string.rep(' ╲', width + 1)

  return setmetatable({
    bufnr = opts.bufnr,
    ns_id = opts.ns_id,
    start_line = opts.start_line - 1,
    end_line = opts.end_line - 1,
    ids = {},
    first_line = first_line,
    second_line = second_line,
    current_index = 1,
    timer = vim.uv.new_timer(),
    opts = vim.tbl_deep_extend('force', spinner_opts, opts.opts or {}),
  }, { __index = VirtualTextBlockSpinner })
end

--- Gets the virtual text content for the spinner based on line and current animation frame
--- @param i number The line number to get virtual text for
--- @return table[] Virtual text for the extmark in the format required by nvim_buf_set_extmark
function VirtualTextBlockSpinner:get_virtual_text(i)
  if (i + self.current_index) % 2 == 0 then
    return { { self.first_line, self.opts.hl_group } }
  else
    return { { self.second_line, self.opts.hl_group } }
  end
end

--- Sets up new extmarks for all lines in the spinner range
--- Creates extmarks for each line and stores their IDs
--- @private
function VirtualTextBlockSpinner:set_new_extmarks()
  self.ids = {}
  for i = self.start_line, self.end_line do
    self.ids[i] = vim.api.nvim_buf_set_extmark(
      self.bufnr,
      self.ns_id,
      i,
      0,
      vim.tbl_deep_extend('force', self.opts.extmark, { virt_text = self:get_virtual_text(i) })
    )
  end
end

--- Updates existing extmarks with new virtual text content based on the current animation frame
--- This method is called by the timer to update the spinner animation
--- @private
function VirtualTextBlockSpinner:set_extmarks()
  for i, id in pairs(self.ids) do
    local current_pos = vim.api.nvim_buf_get_extmark_by_id(self.bufnr, self.ns_id, id, {})
    vim.api.nvim_buf_set_extmark(
      self.bufnr,
      self.ns_id,
      current_pos[1],
      0,
      vim.tbl_deep_extend('force', self.opts.extmark, { virt_text = self:get_virtual_text(i), id = id })
    )
  end
end

--- Starts the spinner animation
--- Creates extmarks for each line in the range and starts the timer to update spinner animation
--- The spinner will continue to animate until the stop method is called
function VirtualTextBlockSpinner:start()
  self:set_new_extmarks()
  self.timer:start(
    0,
    self.opts.repeat_interval,
    vim.schedule_wrap(function()
      self.current_index = self.current_index % 2 + 1
      self:set_extmarks()
    end)
  )
end

--- Stops the spinner animation
--- Cleans up the timer resources and removes all extmarks created for the spinner
--- This method should always be called when the spinner is no longer needed to prevent memory leaks
function VirtualTextBlockSpinner:stop()
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end
  if self.opts.extmark then
    for _, id in pairs(self.ids) do
      vim.schedule(function() vim.api.nvim_buf_del_extmark(self.bufnr, self.ns_id, id) end)
    end
  end
end

return VirtualTextBlockSpinner
