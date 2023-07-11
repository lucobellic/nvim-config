local Flash = require("flash")

---@param opts Flash.Format
local function format(opts)
  -- always show first and second label
  return {
    { opts.match.label1, "FlashMatch" },
    { opts.match.label2, "FlashLabel" },
  }
end

local function jump_word()
  require('flash').jump({
    search = { mode = "search" },
    label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
    pattern = [[\<]],
    action = function(match, state)
      state:hide()
      Flash.jump({
        search = { max_length = 0 },
        highlight = { matches = false },
        label = { format = format },
        matcher = function(win)
          -- limit matches to the current label
          return vim.tbl_filter(function(m)
            return m.label == match.label and m.win == win
          end, state.results)
        end,
        labeler = function(matches)
          for _, m in ipairs(matches) do
            m.label = m.label2 -- use the second label
          end
        end,
      })
    end,
    labeler = function(matches, state)
      local labels = state:labels()
      for m, match in ipairs(matches) do
        match.label1 = labels[math.floor((m - 1) / #labels) + 1]
        match.label2 = labels[(m - 1) % #labels + 1]
        match.label = match.label1
      end
    end,
  })
end

local function jump_word_begin()
  require("flash").jump({
    search = {
      mode = function(str)
        return "\\<" .. str
      end,
    },
  })
end

local function jump_select_word()
  require("flash").jump({
    pattern = ".", -- initialize pattern with any char
    search = {
      mode = function(pattern)
        -- remove leading dot
        if pattern:sub(1, 1) == "." then
          pattern = pattern:sub(2)
        end
        -- return word pattern and proper skip pattern
        return ([[\v<%s\w*>]]):format(pattern), ([[\v<%s]]):format(pattern)
      end,
    },
    -- select the range
    jump = { pos = "range" },
  })
end

local function jump_line()
  require("flash").jump({
    search = { mode = "search", max_length = 0 },
    label = { after = { 0, 0 } },
    pattern = "^"
  })
end

return {
  'folke/flash.nvim',
  keys = {
    {
      '<leader>k',
      function() require("flash").jump() end,
      desc = 'Flash Range'
    },
    {
      '<leader>j',
      jump_word,
      desc = 'Flash Word',
    },
    {
      '<leader>l',
      jump_line,
      desc = 'Flash Line'
    }

  }
}
