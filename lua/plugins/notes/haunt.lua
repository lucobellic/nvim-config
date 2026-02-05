local function select_annotations_session()
  local data_dir = vim.fn.stdpath('data') .. '/haunt'
  local annotations = vim.fn.readdir(data_dir)

  ---@type snacks.picker.finder.Item[]
  local items = vim
    .iter(ipairs(annotations or {}))
    :map(
      function(idx, item)
        return {
          formatted = item,
          text = idx .. '. ' .. item,
          item = item,
          idx = idx,
        }
      end
    )
    :totable()

  Snacks.picker.pick({
    source = 'select',
    items = items,
    format = 'text',
    title = 'Select Annotation Bookmarks',
    layout = { layout = { preview = false } },
    actions = {
      remove = function(picker)
        local items = picker:selected({ fallback = true })
        vim.iter(items):each(function(item) vim.fn.delete(data_dir .. '/' .. item.item, 'rf') end)
      end,
      confirm = function(picker, item)
        picker:close()
        require('haunt.api').change_data_dir(data_dir .. '/' .. item.item)
      end,
    },
    win = { input = { keys = { ['<c-x>'] = { 'remove', mode = { 'i', 'n' } } } } },
  })
end

local function create_new_annotation_session()
  vim.ui.input({ prompt = 'New Annotation Bookmarks' }, function(input)
    if not input or input:match('^%s*$') then
      return
    end
    local data_dir = vim.fn.stdpath('data') .. '/haunt/' .. input
    if vim.fn.isdirectory(data_dir) == 0 then
      vim.fn.mkdir(data_dir, 'p')
    end
    require('haunt.api').change_data_dir(data_dir)
  end)
end

return {
  {
    'folke/which-key.nvim',
    optional = true,
    opts = {
      spec = {
        { '<leader>nb', group = 'bookmarks' },
      },
    },
  },
  {
    'TheNoeTrevino/haunt.nvim',
    event = { 'User LazyBufEnter' },
    ---@class HauntConfig
    keys = {
      { '<leader>na', function() require('haunt.api').annotate() end, desc = 'Haunt Annotate' },
      { '<leader>nt', function() require('haunt.api').toggle_annotation() end, desc = 'Haunt Toggle' },
      { '<leader>nT', function() require('haunt.api').toggle_all_lines() end, desc = 'Haunt Toggle All' },
      { '<leader>nd', function() require('haunt.api').delete() end, desc = 'Haunt Delete Bookmark' },
      { '<leader>nD', function() require('haunt.api').clear_all() end, desc = 'Haunt Delete All Bookmarks' },

      -- move
      { '[n', function() require('haunt.api').prev() end, desc = 'Haunt Previous Bookmark', repeatable = true },
      { ']n', function() require('haunt.api').next() end, desc = 'Haunt Next Bookmark', repeatable = true },

      -- picker
      { '<leader>ns', function() require('haunt.picker').show() end, desc = 'Haunt Show Picker' },

      -- quickfix
      { '<leader>nq', function() require('haunt.api').to_quickfix() end, desc = 'Haunt Send Hauntings to qflist' },
      {
        '<leader>nQ',
        function() require('haunt.api').to_quickfix({ current_buffer = true }) end,
        desc = 'Haunt Send All to qflist',
      },

      -- Load annotation bookmark
      { '<leader>nbs', select_annotations_session, desc = 'Haunt Select Annotation Bookmarks' },
      { '<leader>nbn', create_new_annotation_session, desc = 'Haunt New Annotation Bookmarks' },
    },
    opts = {
      sign = '',
      sign_hl = 'DiagnosticInfo',
      virt_text_hl = 'HauntAnnotation',
      annotation_prefix = '󱙝 ',
      annotation_suffix = '   ',
      virt_text_pos = 'eol_right_align',
      per_branch_bookmarks = false,
      data_dir = vim.fn.stdpath('data') .. '/haunt/default',
      picker = 'snacks', -- "auto", "snacks", "telescope", or "fzf"
      picker_keys = { -- picker agnostic, we got you covered
        delete = { key = '<c-x>', mode = { 'i', 'n' } },
        edit_annotation = { key = '<c-e>', mode = { 'i', 'n' } },
      },
    },
    config = function(_, opts)
      ---@diagnostic disable-next-line: duplicate-set-field
      require('haunt').setup_autocmds = function() end -- disable intempestive annotation writes
      require('haunt').setup(opts)
    end,
  },
}
