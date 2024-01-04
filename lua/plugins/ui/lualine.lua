local colors = {
  darkblue = '#152538',
  inactive = '#1B2733',
  darkgray = '#636B74',
  black = '#0F131A',
  white = '#BFBDB6',
  red = '#F07178',
  purple = '#D2A6FF',
  green = '#AAD94C',
  blue = '#59C2FF',
  orange = '#FFB454',
}

local ayu_gloom_theme = {
  normal = {
    a = { bg = colors.darkblue, fg = colors.white, gui = 'italic' },
    b = { fg = colors.darkgray },
    c = { fg = colors.darkgray },
  },
  insert = {
    a = { bg = colors.green, fg = colors.black, gui = 'italic' },
    b = { fg = colors.green },
    c = { fg = colors.green },
  },
  visual = {
    a = { bg = colors.orange, fg = colors.black, gui = 'italic' },
    b = { fg = colors.orange },
    c = { fg = colors.orange },
  },
  replace = {
    a = { bg = colors.purple, fg = colors.black, gui = 'italic' },
    b = { fg = colors.purple },
    c = { fg = colors.purple },
  },
  command = {
    a = { bg = colors.blue, fg = colors.black, gui = 'italic' },
    b = { fg = colors.blue },
    c = { fg = colors.blue },
  },
  terminal = {
    a = { bg = colors.purple, fg = colors.black, gui = 'italic' },
    b = { fg = colors.purple },
    c = { fg = colors.purple },
  },
  inactive = {
    a = { fg = colors.darkblue, gui = 'italic' },
    b = { fg = colors.inactive },
    c = { fg = colors.inactive },
  },
}

return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'arkav/lualine-lsp-progress',
    'AndreM222/copilot-lualine',
  },
  opts = {
    options = {
      theme = ayu_gloom_theme,
      component_separators = '╱',
      section_separators = { left = '', right = '' },
      refresh = {
        statusline = 200,
        tabline = 200,
        winbar = 200,
      },
    },
    sections = {
      lualine_a = { { 'branch', icon = '' } },
      lualine_b = {
        -- stylua: ignore
        {
          function() return require("noice").api.status.mode.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
        },
        -- stylua: ignore
        {
          function() return "  " .. require("dap").status() end,
          cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
        },
        {
          'overseer',
          colored = true,
          label = '',
          symbols = {
            ['FAILURE'] = ' ',
            ['CANCELED'] = ' ',
            ['SUCCESS'] = ' ',
            ['RUNNING'] = ' ',
          },
        },
      },
      lualine_c = {},
      lualine_x = {
        { 'copilot' },
        {
          'lsp_progress',
          display_components = { 'lsp_client_name', 'spinner' },
          timer = { progress_enddelay = 200, spinner = 200, lsp_client_name_enddelay = 200 },
          spinner_symbols = { '', '', '', '' },
          colors = {
            use = false,
          },
        },
      },
      lualine_y = {
        {
          'searchcount',
          separator = '',
          maxcount = 999,
          timeout = 500,
        },
        {
          'progress',
          separator = ' ',
          padding = { left = 1, right = 0 },
        },
        {
          'location',
          padding = { left = 0, right = 1 },
        },
      },
      lualine_z = {
        function() return os.date('%R') end,
      },
    },
  },
}
