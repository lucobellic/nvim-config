local Flash = require('flash')

---@param opts Flash.Format
local function format(opts)
  -- always show first and second label
  return {
    { opts.match.label1, 'FlashMatch' },
    { opts.match.label2, 'FlashLabel' },
  }
end

---@param match Flash.Match
local function add_fold(match)
  vim.api.nvim_win_call(match.win, function()
    local fold = vim.fn.foldclosed(match.pos[1])
    match.fold = fold ~= -1 and fold or nil
  end)
end

local function label2_jump(multi_window, pattern)
  Flash.jump({
    search = { mode = 'search', multi_window = multi_window },
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
          return vim.tbl_filter(function(m) return m.label == match.label and m.win == win end, state.results)
        end,
        labeler = function(matches)
          for _, m in ipairs(matches) do
            m.label = m.label2 -- use the second label
          end
        end,
      })
    end,
    matcher = function(win, _state, _opts)
      local Search = require('flash.search')
      local search = Search.new(win, _state)
      local matches = {} ---@type Flash.Match[]
      local folds = {} ---@type table<number, boolean>

      for _, match in ipairs(search:get(_opts)) do
        local skip = false
        add_fold(match)

        -- Only label the first match in each fold
        if not skip and match.fold then
          if folds[match.fold] then
            skip = true
          else
            folds[match.fold] = true
          end
        end
        if not skip then
          table.insert(matches, match)
        end
      end
      return matches
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
        function() require('flash').jump({ search = { multi_window = false } }) end,
        desc = 'Flash Range',
        mode = { 'n', 'v' },
      },
      {
        'S',
        function() require('flash').jump() end,
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
        '<leader>L',
        function() label2_jump(true, '^') end,
        desc = 'Flash Word',
        mode = { 'n', 'v' },
      },
      {
        '<c-s>',
        mode = { 'c' },
        require('flash').toggle,
        desc = 'Flash Toggle Search',
      },
      {
        '<c-s>',
        mode = { 'i' },
        function()
          require('flash').jump({
            pattern = '^',
            search = {
              mode = 'search',
              label = { after = { 0, 0 } },
              pattern = '^',
              exclude = {
                function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'cmp_menu' end,
              },
            },
            action = function(match)
              local cmp = require('cmp')
              local active_entry = cmp.get_entries()[match.pos[1]] ---@type cmp.Entry
              cmp.core:confirm(active_entry, { behavior = cmp.ConfirmBehavior.Replace }, function() end)
              cmp.close()
            end,
          })
        end,
        desc = 'Flash Cmp Search',
      },
      {
        'r',
        mode = 'o',
        require('flash').remote,
        desc = 'Flash Remote',
      },
      {
        'R',
        mode = { 'o', 'x' },
        require('flash').treesitter_search,
        desc = 'Flash Treesitter Search',
      },
    }
  end,
  opts = {
    jump = { autojump = false },
    modes = {
      search = {
        enabled = false,
        highlight = {
          backdrop = true,
        },
      },
    },
    prompt = { enabled = false },
  },
  config = function(_, opts)
    require('flash').setup(opts)
    if vim.g.vscode then
      vim.api.nvim_set_hl(0, 'FlashLabel', { fg = '#c1d94a' })
      vim.api.nvim_set_hl(0, 'FlashMatch', { fg = '#37bbe6' })
    end
  end,
}
