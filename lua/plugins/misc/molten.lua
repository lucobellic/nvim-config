local is_kitty = vim.fn.match(os.getenv('TERM'), 'kitty') ~= -1
local is_wezterm = true -- os.getenv('TERM_PROGRAM') == 'WezTerm'

local kitty_dependencies = {
  {
    'vhyrro/luarocks.nvim',
    priority = 1001, -- this plugin needs to run before anything else
    opts = {
      rocks = { 'magick', 'fzy' },
    },
  },
  {
    '3rd/image.nvim',
    dependencies = { 'luarocks.nvim' },
    opts = {
      backend = 'kitty',
    },
  },
}

local wezterm_dependencies = {
  'willothy/wezterm.nvim',
  config = true,
}

local dependencies = is_kitty and kitty_dependencies or is_wezterm and wezterm_dependencies or {}
local image_provider = is_kitty and 'image.nvim' or is_wezterm and 'wezterm' or ''

local function evaluate_pypercent()
  local pattern = '%%'
  -- Find first and last line number containing #%%
  -- flags:
  --  - W : no wrap around
  --  - b : backward
  --  - n : do not move the cursor
  local first = vim.fn.search(pattern, 'Wbn') + 1
  local last = vim.fn.search(pattern, 'Wn')
  last = last == 0 and vim.api.nvim_buf_line_count(0) or last - 1
  vim.fn.MoltenEvaluateRange(first, last)
end

return {
  {
    'benlubas/molten-nvim',
    dependencies = dependencies,
    build = ':UpdateRemotePlugins',
    event = 'Bufenter *.py,*.ipynb',
    keys = {
      { '<leader>mi', '<cmd>MoltenInit<CR>', desc = 'Molten Init' },
      { '<leader>me', '<cmd>MoltenEvaluateOperator<CR>', desc = 'Molten Evaluate Operator' },
      { '<leader>mc', '<cmd>MoltenReevaluateCell<CR>', desc = 'Molten Reevaluate Cell' },
      { '<leader>md', '<cmd>MoltenDelete<CR>', desc = 'Molten Delete' },
      { '<leader>mh', '<cmd>MoltenHideOutput<CR>', desc = 'Molten Hide Output' },
      { '<leader>mo', ':noautocmd MoltenEnterOutput<CR>', desc = 'Molten Enter Output' },
      {
        '<leader>ms',
        function() evaluate_pypercent() end,
        desc = 'Molten Percent',
      },
      { '<leader>ml', '<cmd>MoltenEvaluateLine<CR>', desc = 'Molten Evaluate Line' },
      {
        '<leader>ml',
        ':<C-U>MoltenEvaluateVisual<CR>gv',
        mode = 'v',
        desc = 'Molten Evaluate Visual',
      },
    },
    init = function()
      vim.g.molten_image_provider = image_provider
      vim.g.molten_output_win_border = { '', '-', '', '' }
      vim.g.molten_virt_text_output = false
      if vim.g.molten_image_provider == 'wezterm' then
        vim.g.molten_auto_open_output = false
      end
    end,
  },
}
