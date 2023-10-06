local Flash = require("flash")

---@param opts Flash.Format
local function format(opts)
  -- always show first and second label
  return {
    { opts.match.label1, "FlashMatch" },
    { opts.match.label2, "FlashLabel" },
  }
end

local function label2_jump(multi_window, pattern)
  require('flash').jump({
    search = { mode = "search", multi_window = multi_window },
    label = { after = false, before = { 0, 0 }, uppercase = false, format = format },
    pattern = pattern,
    action = function(match, state)
      state:hide()
      Flash.jump({
        search = { max_length = 0, multi_window = multi_window },
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

return {
  'folke/flash.nvim',
  keys = function()
    return {
      {
        's',
        function() require("flash").jump({ search = { multi_window = false } }) end,
        desc = 'Flash Range',
        mode = { 'n', 'v' },
      },
      {
        'S',
        function() require("flash").jump() end,
        desc = 'Flash Range',
        mode = { 'n' },
      },
      {
        '<leader>j',
        function() label2_jump(false, [[\<]]) end,
        desc = 'Flash Word',
        mode = { 'n', 'v' },
      },
      {
        '<leader>J',
        function() label2_jump(true, [[\<]]) end,
        desc = 'Flash Word',
        mode = { 'n', 'v' },
      },
      {
        '<leader>l',
        function() label2_jump(false, '^') end,
        desc = 'Flash Word',
        mode = { 'n', 'v' },
      },
      {
        "<leader>L",
        function() label2_jump(true, '^') end,
        desc = 'Flash Word',
        mode = { 'n', 'v' },
      },
      {
        "<c-s>",
        mode = { "c" },
        require("flash").toggle,
        desc = "Toggle Flash Search"
      },
      {
        "r",
        mode = "o",
        require("flash").remote,
        desc = "Remote Flash"
      },
      {
        "R",
        mode = { "o", "x" },
        require("flash").treesitter_search,
        desc = "Treesitter Search"
      },
    }
  end,
  opts = {
    jump = { autojump = false },
    modes = { search = { highlight = { backdrop = true } } },
    prompt = { enabled = false, },
  }
}
