--- Override the default rainbow colors with custom ones
--- @param idx number The index of the color in the rainbow table
--- @param shade number? The shade multiplier (default: 5)
--- @return string | nil highlight group name if color is found
local function get_rainbow_colors(idx, shade)
  local Rainbow = require('flash.rainbow')
  Rainbow.setup()

  -- Normalize idx to be within the rainbow table bounds
  idx = (idx - 1) % #Rainbow.rainbow + 1

  local color = Rainbow.rainbow[idx]
  shade = (shade or 5) * 100

  local fg = vim.tbl_get(Rainbow.colors, color, shade)
  if not fg then
    return nil
  end

  local hl = 'FlashColor' .. color .. shade
  if not Rainbow.hl[hl] then
    Rainbow.hl[hl] = true
    vim.api.nvim_set_hl(0, hl, { fg = '#' .. fg, italic = true })
  end

  return hl
end

--- @param opts Flash.Format
local function format(opts)
  -- always show first and second label
  return {
    { opts.match.label1, 'FlashMatch' },
    { opts.match.label2, 'FlashLabel' },
  }
end

--- @param match Flash.Match
local function add_fold(match)
  vim.api.nvim_win_call(match.win, function()
    local fold = vim.fn.foldclosed(match.pos[1])
    match.fold = fold ~= -1 and fold or nil
  end)
end

local function label2_jump(multi_window, pattern)
  local Flash = require('flash')
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
                function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'blink-cmp-menu' end,
              },
            },
            action = function(match)
              vim.schedule(function() require('blink.cmp.completion.list').accept({ index = match.pos[1] }) end)
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
        function() require('flash').treesitter_search({ label = { rainbow = { enabled = true, shade = 4 } } }) end,
        desc = 'Flash Treesitter Search',
      },
    }
  end,
  opts = {
    jump = { autojump = false },
    modes = {
      char = {
        jump_labels = true,
        config = function(opts)
          -- Disable in operator-pending mode
          opts.jump_labels = opts.jump_labels and not vim.fn.mode(true):find('no')
        end,
        char_actions = function(motion)
          return {
            [';'] = 'right',
            [','] = 'left',
            [motion:lower()] = 'right',
            [motion:upper()] = 'left',
          }
        end,
      },
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
    require('flash.rainbow').get_color = get_rainbow_colors

    if vim.g.vscode then
      vim.api.nvim_set_hl(0, 'FlashLabel', { fg = '#c1d94a' })
      vim.api.nvim_set_hl(0, 'FlashMatch', { fg = '#37bbe6' })
    end
  end,
}
