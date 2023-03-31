local gl = require("galaxyline")
local gls = gl.section
gl.short_line_list = { " " }

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

gls.left[1] = {
    Space = {
        provider = function()
            return ""
        end,
        highlight = { colors.bg, colors.bg }
    }
}

gls.left[2] = {
    ViMode = {
        provider = function()
            vim.api.nvim_command('hi GalaxyViMode guifg=' .. mode_color())
            -- return ' ' .. '  ' .. os.date('%H:%M') .. ' '
            return '▌ ' .. os.date('%H:%M') .. ' '
            -- return '▌  '
            -- 
        end,
        separator = " ",
    }
}

gls.left[3] = {
    FileIcon = {
        provider = "FileIcon",
        condition = buffer_not_empty,
        highlight = { require("galaxyline.provider_fileinfo").get_file_icon_color, colors.bg }
    }
}

gls.left[4] = {
    FileName = {
        provider = { "FileName" },
        condition = buffer_not_empty,
        highlight = { colors.fg, colors.bg },
        separator = " ",
    }
}

gls.left[5] = {
    GitBranch = {
        provider = "GitBranch",
        icon = " ",
        condition = require("galaxyline.provider_vcs").check_git_workspace,
        separator = " ",
        highlight = { colors.green, colors.bg }
    }
}

gls.left[6] = {
    DiffAdd = {
        provider = "DiffAdd",
        icon = "  ",
        highlight = { colors.green, colors.bg }
    }
}

gls.left[7] = {
    DiffModified = {
        provider = "DiffModified",
        icon = "  ",
        highlight = { colors.blue, colors.bg }
    }
}

gls.left[8] = {
    DiffRemove = {
        provider = "DiffRemove",
        icon = "  ",
        highlight = { colors.red, colors.bg }
    }
}

gls.left[9] = {
    Space = {
        provider = function()
            return  " "
        end,
        highlight = { colors.bg, colors.bg }
    }
}

gls.left[10] = {
    DiagnosticError = {
        provider = "DiagnosticError",
        icon = "  ",
        highlight = { colors.red, colors.bg }
    }
}

gls.left[11] = {
    DiagnosticWarn = {
        provider = "DiagnosticWarn",
        icon = "  ",
        highlight = { colors.orange, colors.bg }
    }
}

gls.right[1] = {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = function ()
      local tbl = {['dashboard'] = true,['']=true}
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    icon = ' ',
    highlight = {colors.magenta, colors.bg},
    separator = " "
  }
}

gls.right[2] = {
    LineInfo = {
        provider = function()
            return string.format("%3d", vim.fn.col('.'))
        end,
        separator = " "
    }
}

gls.right[3] = {
    PerCent = {
        provider = "LinePercent",
        separator = " ",
        highlight = { colors.fg, colors.bg }
    }
}
