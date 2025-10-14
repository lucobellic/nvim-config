--- @class VirtualTextBlockSpinner.SpinnerOpts
--- @field hl_group string Highlight group for the spinner
--- @field repeat_interval number Interval in milliseconds to update the spinner
--- @field extmark vim.api.keyset.set_extmark Extmark options passed to nvim_buf_set_extmark
--- @field patterns? table<string> Table of spinner patterns to cycle through
local spinner_opts = {
  hl_group = 'Comment',
  repeat_interval = 100,
  extmark = {
    virt_text_pos = 'overlay',
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
--- @field patterns table<string> Table of spinner patterns to cycle through
--- @field current_index number Current index in the spinner patterns array
--- @field timer uv.uv_timer_t | nil Timer used to update spinner animation
--- @field opts VirtualTextBlockSpinner.SpinnerOpts Configuration options for the spinner
--- @field width number The width of the spinner content
--- @field height number The height of the spinner content
--- @field border_top string Top border of the spinner
--- @field border_bottom string Bottom border of the spinner
local VirtualTextBlockSpinner = {
  bufnr = 0,
  ns_id = 0,
  start_line = 0,
  end_line = 0,
  ids = {},
  patterns = {},
  current_index = 1,
  timer = nil,
  opts = spinner_opts,
  width = 0,
  height = 0,
  border_top = '',
  border_bottom = '',
}

--- @class VirtualTextBlockSpinner.Opts
--- @field bufnr number Buffer number where the spinner will be shown
--- @field ns_id number Namespace ID for the extmarks
--- @field start_line number Starting line (1-indexed) for the spinner
--- @field end_line number Ending line (1-indexed) for the spinner
--- @field opts? VirtualTextBlockSpinner.SpinnerOpts Optional configuration options

--- Creates a new VirtualTextBlockSpinner instance
--- @param opts VirtualTextBlockSpinner.Opts Options for the spinner
--- @return VirtualTextBlockSpinner self New spinner instance
function VirtualTextBlockSpinner.new(opts)
  local lines = vim.api.nvim_buf_get_lines(opts.bufnr, opts.start_line - 1, opts.end_line, false)
  local width = vim.fn.max(vim.iter(lines):map(function(line) return vim.fn.strdisplaywidth(line) end):totable())
  local window_width = vim.api.nvim_win_get_width(0) - 6
  width = math.min(width, window_width)

  local merged_opts = vim.tbl_deep_extend('force', spinner_opts, opts.opts or {})
  local patterns = {}

  -- First determine the raw patterns
  local raw_patterns = {
    '╲  ',
    ' ╲ ',
    '  ╲',
  }

  if merged_opts.patterns and #merged_opts.patterns > 0 then
    raw_patterns = merged_opts.patterns --- @type string[]
  end

  -- Calculate required repetitions to match the content width
  --- @diagnostic disable-next-line: need-check-nil
  local pattern_width = vim.fn.strdisplaywidth(raw_patterns[1])
  local repetitions = pattern_width > 0 and math.ceil(width / pattern_width) or width
  width = repetitions * pattern_width
  local horizontal_line = string.rep('─', width)

  -- Now create the final patterns with proper repetition
  for _, pattern in ipairs(raw_patterns) do
    table.insert(patterns, string.rep(pattern, repetitions))
  end

  return setmetatable({
    bufnr = opts.bufnr,
    ns_id = opts.ns_id,
    start_line = opts.start_line - 1,
    end_line = opts.end_line - 1,
    ids = {},
    patterns = patterns,
    current_index = 1,
    timer = vim.uv.new_timer(),
    opts = merged_opts,
    width = width,
    height = #lines,
    border_top = '╭' .. horizontal_line .. '╮',
    border_bottom = '╰' .. horizontal_line .. '╯',
  }, { __index = VirtualTextBlockSpinner })
end

--- Gets the virtual text content for the spinner based on line and current animation frame
--- @param i number The line number to get virtual text for
--- @return table[] Virtual text for the extmark in the format required by nvim_buf_set_extmark
function VirtualTextBlockSpinner:get_virtual_text(i)
  local pattern_index = ((i + self.current_index - 1) % #self.patterns) + 1
  local pattern = self.patterns[pattern_index]

  if self.height <= 2 then
    return { { pattern, self.opts.hl_group } }
  end

  -- First line (top border)
  if i == self.start_line then
    return { { self.border_top, self.opts.hl_group } }
  end

  -- Last line (bottom border)
  if i == self.end_line then
    return { { self.border_bottom, self.opts.hl_group } }
  end

  -- Middle lines with spinner animation
  return { { '│' .. pattern .. '│', self.opts.hl_group } }
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
    pcall(
      function()
        vim.api.nvim_buf_set_extmark(
          self.bufnr,
          self.ns_id,
          current_pos[1],
          0,
          vim.tbl_deep_extend('force', self.opts.extmark, { virt_text = self:get_virtual_text(i), id = id })
        )
      end
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
      self.current_index = (self.current_index % #self.patterns) + 1
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
