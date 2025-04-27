--- @class VirtualTextSpinner.Opts
--- @field spinner_text string Text to display before the spinner
--- @field spinner_frames string[] Spinner frames to use for the spinner
--- @field hl_group string Highlight group for the spinner
--- @field repeat_interval number Interval in milliseconds to update the spinner
--- @field extmark vim.api.keyset.set_extmark Extmark options passed to nvim_buf_set_extmark

--- @type VirtualTextSpinner.Opts
local spinner_opts = {
  spinner_text = 'Processing',
  spinner_frames = { '⣷', '⣯', '⣟', '⡿', '⢿', '⣻', '⣽', '⣾' },
  hl_group = 'DiagnosticVirtualTextWarn',
  repeat_interval = 100,
  extmark = {
    virt_text_pos = 'inline',
    priority = 1000,
  },
}

--- @class VirtualTextSpinner
--- @field bufnr number The buffer number where the spinner is displayed
--- @field ns_id number The namespace ID for the extmark
--- @field line_num number The line number where the spinner is displayed
--- @field current_index number Current index in the spinner frames array
--- @field timer uv.uv_timer_t | nil Timer used to update spinner animation
--- @field opts VirtualTextSpinner.Opts Configuration options for the spinner
local VirtualTextSpinner = {
  bufnr = 0,
  ns_id = 0,
  line_num = 0,
  current_index = 1,
  timer = nil,
  opts = spinner_opts,
}

--- Creates a new VirtualTextSpinner instance
--- @param bufnr number Buffer number to display the spinner in
--- @param ns_id number Namespace ID for the extmark
--- @param line_num number Line number to display the spinner on (1-indexed)
--- @param opts? VirtualTextSpinner.Opts Optional configuration options
--- @return VirtualTextSpinner self New spinner instance
function VirtualTextSpinner.new(bufnr, ns_id, line_num, opts)
  local self = setmetatable({}, { __index = VirtualTextSpinner })
  self.bufnr = bufnr
  self.ns_id = ns_id
  self.line_num = line_num - 1
  self.current_index = 1
  self.timer = vim.uv.new_timer()
  self.opts = vim.tbl_deep_extend('force', spinner_opts, opts or {})
  return self
end

--- Gets the virtual text content for the spinner
--- @return table[]
function VirtualTextSpinner:get_virtual_text()
  return { { self.opts.spinner_text .. ' ' .. self.opts.spinner_frames[self.current_index] .. ' ', self.opts.hl_group } }
end

--- @private
--- @return number id of the extmark
function VirtualTextSpinner:set_extmark()
  return vim.api.nvim_buf_set_extmark(self.bufnr, self.ns_id, self.line_num, 0, self.opts.extmark)
end

--- Starts the spinner animation
--- Creates the extmark and starts the timer to update the spinner frames
function VirtualTextSpinner:start()
  self.opts.extmark.virt_text = self:get_virtual_text()
  self.opts.extmark.id = self:set_extmark()
  self.timer:start(
    0,
    self.opts.repeat_interval,
    vim.schedule_wrap(function()
      self.current_index = self.current_index % #self.opts.spinner_frames + 1
      self.opts.extmark.virt_text = self:get_virtual_text()
      self:set_extmark()
    end)
  )
end

--- Stops the spinner animation
--- Cleans up the timer and removes the extmark
function VirtualTextSpinner:stop()
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end
  if self.opts.extmark then
    vim.schedule(function() vim.api.nvim_buf_del_extmark(self.bufnr, self.ns_id, self.opts.extmark.id) end)
  end
end

return VirtualTextSpinner
