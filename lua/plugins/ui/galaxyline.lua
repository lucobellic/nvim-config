local gl = require("galaxyline")
local gls = gl.section

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

gls.left[1] = {
  Space = {
    provider = function()
      return " "
    end,
  },
}

gls.left[2] = {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = function()
      local tbl = { ['dashboard'] = true, [''] = true }
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    icon = '  ',
    highlight = { colors.magenta },
    separator = " "
  }
}


-- NOTE: To center mid section on screen update galaxyline.lua:200 replace with the following:
-- local mid_screen = math.floor(vim.api.nvim_get_option("columns") / 2)
-- local left_width = vim.api.nvim_eval_statusline(left_section, {}).width
-- local mid_width = vim.api.nvim_eval_statusline(mid_section, {}).width
-- local left_padding = string.rep(' ', mid_screen - math.floor(mid_width / 2) - left_width)
-- line = left_section .. left_padding .. mid_section .. fill_section .. right_section
gls.mid[1] = {
  ViMode = {
    provider = function()
      vim.api.nvim_command('hi GalaxyViMode guifg=#0F131A guibg=' .. mode_color())
      return ' ' .. os.date('%H:%M') .. ' '
    end,
    separator = "  ",
  }
}

gls.right[1] = {
  LineInfo = {
    provider = function()
      return string.format("%3d", vim.fn.col('.'))
    end,
    separator = " "
  }
}

gls.right[2] = {
  PerCent = {
    provider = "LinePercent",
    separator = " ",
  }
}
