return {
  'nvim-lualine/lualine.nvim',
  enabled = false,
  opts = {
    options = {
      theme = 'auto',
      component_separators = '|',
      section_separators = { left = '', right = '' },
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
      },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {
        -- stylua: ignore
        {
          'progress',
          separator = ' ',
          padding = { left = 1, right = 0 }
        },
        {
          'location',
          padding = { left = 0, right = 1 }
        },
      },
      lualine_z = {
        function()
          return '  ' .. os.date('%R')
        end,
      },
    },
  }
}
