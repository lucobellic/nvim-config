local gl = require("galaxyline")
local gls = gl.section

local fileinfo = require('galaxyline.provider_fileinfo')
local lspclient = require('galaxyline.provider_lsp')

local colors = {
  bg = "Normal",
  line_bg = "CursorLine",
  fg = "Normal",
  accent = "#FF8F40",
  fg_green = "#C2D9RC",
  yellow = "#A3BE8C",
  cyan = "#39BAE6",
  darkblue = "#61afef",
  green = "#BBE67E",
  orange = "#F29668",
  purple = "#252930",
  magenta = "#C678DD",
  blue = "#39BAE6",
  red = "#F07178",
  lightbg = "#3C4048",
  nord = "#81A1C1",
  greenYel = "#EBCB8B"
}

local mode_color = function()
  local mode_colors = {
    n = colors.cyan,
    i = colors.green,
    t = colors.green,
    c = colors.accent,
    V = colors.greenYel,
    [""] = colors.greenYel,
    v = colors.greenYel,
    R = colors.magenta,
    r = colors.magenta
  }

  local color = mode_colors[vim.fn.mode()]

  if color == nil then
    color = colors.cyan
  end

  return color
end

vim.api.nvim_set_hl(0, "GalaxySpace", { link = 'Normal' })

gls.left = {
  {
    ShowLspClient = {
      provider = function()
        vim.api.nvim_command('hi GalaxyShowLspClient guifg=' .. mode_color())
        return lspclient.get_lsp_client()
      end,

      condition = function()
        local tbl = { ['dashboard'] = true, [''] = true }
        if tbl[vim.bo.filetype] then
          return false
        end
        return true
      end,
      icon = '   ',
      separator = " "
    }
  }
}

gls.mid =
{
  {
    ViMode = {
      provider = function()
        vim.api.nvim_command('hi GalaxyViMode guifg=#0F131A guibg=' .. mode_color())
        return ' ' .. os.date('%H:%M') .. ' '
      end,
      separator = "  ",
    }
  }
}

gls.right = {
  {
    LineInfo = {
      provider = function()
        vim.api.nvim_command('hi GalaxyLineInfo guifg=' .. mode_color())
        return string.format("%3d", vim.fn.col('.'))
      end,
      separator = " "
    }
  },
  {
    PerCent = {
      provider = function()
        vim.api.nvim_command('hi GalaxyPerCent guifg=' .. mode_color())
        return fileinfo.current_line_percent()
      end,
      separator = " ",
    }
  }
}
