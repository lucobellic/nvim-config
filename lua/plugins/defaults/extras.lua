--- Extras previously imported from LazyVim distribution.
--- Only includes plugins NOT already configured in user's plugins/ directory.
--- Already in user config: copilot, blink, neogen, dap, snacks_picker,
--- refactoring, indent-blankline, octo, neotest, nvim-lint

--- Prettier formatting support
local prettier_supported = {
  'css',
  'graphql',
  'handlebars',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'less',
  'markdown',
  'markdown.mdx',
  'scss',
  'typescript',
  'typescriptreact',
  'vue',
  'yaml',
}

--- Dial increment/decrement helper
---@param increment boolean
---@param g? boolean
local function dial(increment, g)
  local mode = vim.fn.mode(true)
  local is_visual = mode == 'v' or mode == 'V' or mode == '\22'
  local func = (increment and 'inc' or 'dec') .. (g and '_g' or '_') .. (is_visual and 'visual' or 'normal')
  local group = vim.g.dials_by_ft[vim.bo.filetype] or 'default'
  return require('dial.map')[func](group)
end

--- Dotfile language support: detect filetypes and add treesitter parsers
local xdg_config = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. '/.config'
local function have(path) return vim.uv.fs_stat(xdg_config .. '/' .. path) ~= nil end

--- Mini.hipatterns color highlight support
local hipatterns_hl = {}

return {
  -- Prettier
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'prettier' } },
  },
  {
    'stevearc/conform.nvim',
    optional = true,
    ---@param opts conform.setupOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(prettier_supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 'prettier')
      end
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        condition = function(_, ctx)
          local ft = vim.bo[ctx.buf].filetype
          if vim.tbl_contains(prettier_supported, ft) then
            return true
          end
          local ret = vim.fn.system({ 'prettier', '--file-info', ctx.filename })
          local ok, parser = pcall(function() return vim.fn.json_decode(ret).inferredParser end)
          return ok and parser and parser ~= vim.NIL
        end,
      }
    end,
  },

  -- Dial: increment/decrement
  {
    'monaqa/dial.nvim',
    desc = 'Increment and decrement numbers, dates, and more',
    -- stylua: ignore
    keys = {
      { '<C-a>', function() return dial(true) end, expr = true, desc = 'Increment', mode = { 'n', 'v' } },
      { '<C-x>', function() return dial(false) end, expr = true, desc = 'Decrement', mode = { 'n', 'v' } },
      { 'g<C-a>', function() return dial(true, true) end, expr = true, desc = 'Increment', mode = { 'n', 'x' } },
      { 'g<C-x>', function() return dial(false, true) end, expr = true, desc = 'Decrement', mode = { 'n', 'x' } },
    },
    opts = function()
      local augend = require('dial.augend')

      local logical_alias = augend.constant.new({ elements = { '&&', '||' }, word = false, cyclic = true })
      local ordinal_numbers = augend.constant.new({
        elements = { 'first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth' },
        word = false,
        cyclic = true,
      })
      local weekdays = augend.constant.new({
        elements = { 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' },
        word = true,
        cyclic = true,
      })
      local months = augend.constant.new({
        elements = {
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        },
        word = true,
        cyclic = true,
      })
      local capitalized_boolean = augend.constant.new({ elements = { 'True', 'False' }, word = true, cyclic = true })

      return {
        dials_by_ft = {
          css = 'css',
          vue = 'vue',
          javascript = 'typescript',
          typescript = 'typescript',
          typescriptreact = 'typescript',
          javascriptreact = 'typescript',
          json = 'json',
          lua = 'lua',
          markdown = 'markdown',
          sass = 'css',
          scss = 'css',
          python = 'python',
        },
        groups = {
          default = {
            augend.integer.alias.decimal,
            augend.integer.alias.decimal_int,
            augend.integer.alias.hex,
            augend.date.alias['%Y/%m/%d'],
            ordinal_numbers,
            weekdays,
            months,
            capitalized_boolean,
            augend.constant.alias.bool,
            logical_alias,
          },
          vue = {
            augend.constant.new({ elements = { 'let', 'const' } }),
            augend.hexcolor.new({ case = 'lower' }),
            augend.hexcolor.new({ case = 'upper' }),
          },
          typescript = {
            augend.constant.new({ elements = { 'let', 'const' } }),
          },
          css = {
            augend.hexcolor.new({ case = 'lower' }),
            augend.hexcolor.new({ case = 'upper' }),
          },
          markdown = {
            augend.constant.new({ elements = { '[ ]', '[x]' }, word = false, cyclic = true }),
            augend.misc.alias.markdown_header,
          },
          json = {
            augend.semver.alias.semver,
          },
          lua = {
            augend.constant.new({ elements = { 'and', 'or' }, word = true, cyclic = true }),
          },
          python = {
            augend.constant.new({ elements = { 'and', 'or' } }),
          },
        },
      }
    end,
    config = function(_, opts)
      for name, group in pairs(opts.groups) do
        if name ~= 'default' then
          vim.list_extend(group, opts.groups.default)
        end
      end
      require('dial.config').augends:register_group(opts.groups)
      vim.g.dials_by_ft = opts.dials_by_ft
    end,
  },

  -- Mini.hipatterns: highlight colors in code
  {
    'nvim-mini/mini.hipatterns',
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
    opts = function()
      local hi = require('mini.hipatterns')
      return {
        tailwind = {
          enabled = true,
          ft = {
            'astro',
            'css',
            'heex',
            'html',
            'html-eex',
            'javascript',
            'javascriptreact',
            'rust',
            'svelte',
            'typescript',
            'typescriptreact',
            'vue',
          },
          style = 'full',
        },
        highlighters = {
          hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
          shorthand = {
            pattern = '()#%x%x%x()%f[^%x%w]',
            group = function(_, _, data)
              local match = data.full_match
              local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
              local hex_color = '#' .. r .. r .. g .. g .. b .. b
              return MiniHipatterns.compute_hex_color_group(hex_color, 'bg')
            end,
            extmark_opts = { priority = 2000 },
          },
        },
      }
    end,
    config = function(_, opts)
      if type(opts.tailwind) == 'table' and opts.tailwind.enabled then
        vim.api.nvim_create_autocmd('ColorScheme', {
          callback = function() hipatterns_hl = {} end,
        })
        -- Tailwind CSS color definitions (inlined to avoid LazyVim dependency)
        local tw_colors = require('config.tailwind_colors')
        opts.highlighters.tailwind = {
          pattern = function()
            if not vim.tbl_contains(opts.tailwind.ft, vim.bo.filetype) then
              return
            end
            if opts.tailwind.style == 'full' then
              return '%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]'
            elseif opts.tailwind.style == 'compact' then
              return '%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]'
            end
          end,
          group = function(_, _, m)
            local match = m.full_match
            local color, shade = match:match('[%w-]+%-([a-z%-]+)%-(%d+)')
            shade = tonumber(shade)
            local bg = vim.tbl_get(tw_colors, color, shade)
            if bg then
              local hl = 'MiniHipatternsTailwind' .. color .. shade
              if not hipatterns_hl[hl] then
                hipatterns_hl[hl] = true
                local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
                local fg = vim.tbl_get(tw_colors, color, bg_shade)
                vim.api.nvim_set_hl(0, hl, { bg = '#' .. bg, fg = '#' .. fg })
              end
              return hl
            end
          end,
          extmark_opts = { priority = 2000 },
        }
      end
      require('mini.hipatterns').setup(opts)
    end,
  },

  -- Dotfile language support
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      local function add(lang)
        if type(opts.ensure_installed) == 'table' then
          table.insert(opts.ensure_installed, lang)
        end
      end

      vim.filetype.add({
        extension = { rasi = 'rasi', rofi = 'rasi', wofi = 'rasi' },
        filename = { ['vifmrc'] = 'vim' },
        pattern = {
          ['.*/waybar/config'] = 'jsonc',
          ['.*/mako/config'] = 'dosini',
          ['.*/kitty/.+%.conf'] = 'kitty',
          ['.*/hypr/.+%.conf'] = 'hyprlang',
          ['%.env%.[%w_.-]+'] = 'sh',
        },
      })
      vim.treesitter.language.register('bash', 'kitty')

      add('git_config')
      if have('hypr') then
        add('hyprlang')
      end
      if have('fish') then
        add('fish')
      end
      if have('rofi') or have('wofi') then
        add('rasi')
      end
    end,
  },
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'shellcheck' } },
  },

  -- Language extras: treesitter parsers
  -- (LSP servers are configured via vim.lsp.enable() + after/lsp/ pattern)
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        -- cmake
        'cmake',
        -- docker
        'dockerfile',
        -- git
        'git_config',
        'gitcommit',
        'git_rebase',
        'gitignore',
        'gitattributes',
        -- json
        'json',
        'json5',
        'jsonc',
        -- markdown
        'markdown',
        'markdown_inline',
        -- nix
        'nix',
        -- python
        'ninja',
        'rst',
        -- rust
        'ron',
        'rust',
        -- toml
        'toml',
        -- typescript
        'javascript',
        'jsdoc',
        'typescript',
        'tsx',
        -- yaml
        'yaml',
      },
    },
  },

  -- VSCode integration
  (function()
    if not vim.g.vscode then
      return {}
    end

    local enabled = {
      'dial.nvim',
      'lazy.nvim',
      'mini.ai',
      'mini.pairs',
      'mini.surround',
      'nvim-treesitter',
      'nvim-treesitter-textobjects',
      'snacks.nvim',
      'ts-comments.nvim',
    }

    local Config = require('lazy.core.config')
    Config.options.checker.enabled = false
    Config.options.change_detection.enabled = false
    Config.options.defaults.cond = function(plugin) return vim.tbl_contains(enabled, plugin.name) or plugin.vscode end
    vim.g.snacks_animate = false

    return {
      {
        'snacks.nvim',
        opts = {
          bigfile = { enabled = false },
          dashboard = { enabled = false },
          indent = { enabled = false },
          input = { enabled = false },
          notifier = { enabled = false },
          picker = { enabled = false },
          quickfile = { enabled = false },
          scroll = { enabled = false },
          statuscolumn = { enabled = false },
        },
      },
      {
        'nvim-treesitter/nvim-treesitter',
        opts = { highlight = { enable = false } },
      },
    }
  end)(),
}
