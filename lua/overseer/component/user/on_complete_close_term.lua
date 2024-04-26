local constants = require('overseer.constants')
local STATUS = constants.STATUS

---@type overseer.ComponentFileDefinition
local comp = {
  desc = 'After task is completed, close terminal buffer after a timeout',
  params = {
    timeout = {
      desc = 'Time to wait (in seconds) before disposing',
      default = 300, -- 5 minutes
      type = 'number',
      validate = function(v) return v > 0 end,
    },
    statuses = {
      desc = 'Tasks with one of these statuses will be disposed',
      type = 'list',
      default = { STATUS.SUCCESS, STATUS.FAILURE, STATUS.CANCELED },
      subtype = {
        type = 'enum',
        choices = STATUS.values,
      },
    },
  },
  constructor = function(opts)
    opts = opts or {}
    vim.validate({
      timeout = { opts.timeout, 'n' },
    })
    return {
      timer = nil,
      on_complete = function(self, task)
        if not vim.tbl_contains(opts.statuses, task.status) then
          return
        end
        self.timer = vim.loop.new_timer()
        -- Start a repeating timer because the dispose could fail with a
        -- temporary reason (e.g. the task buffer is open, or the action menu is
        -- displayed for the task)
        self.timer:start(
          1000 * opts.timeout,
          1000 * opts.timeout,
          vim.schedule_wrap(function()
            local bufnr = task:get_bufnr()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.api.nvim_buf_delete(bufnr, { force = true })
              self.timer:close()
              self.timer = nil
            end
          end)
        )
      end,
      on_reset = function(self)
        if self.timer then
          self.timer:close()
          self.timer = nil
        end
      end,
      on_dispose = function(self)
        if self.timer then
          self.timer:close()
          self.timer = nil
        end
      end,
    }
  end,
}

return comp
