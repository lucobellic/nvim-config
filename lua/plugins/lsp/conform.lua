---@type string[]
local prettier_filetypes = {
  'css',
  'graphql',
  'handlebars',
  'html',
  'htmlangular',
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

---@type string[]
local biome_filetypes = {
  'css',
  'graphql',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'svelte',
  'typescript',
  'typescriptreact',
}

---@param bufnr integer
---@return conform.FiletypeFormatterInternal
local function web_formatters(bufnr)
  -- Svelte needs a Prettier plugin, so keep its existing Biome and LSP support.
  ---@type conform.FiletypeFormatterInternal
  local formatters = vim.bo[bufnr].filetype == 'svelte' and {} or { 'prettier' }
  if vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc', '.biome.json', '.biome.jsonc' }) then
    table.insert(formatters, 1, 'biome-check')
    formatters.stop_after_first = true
  end
  return formatters
end

return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    {
      'mason-org/mason.nvim',
      ---@param _ LazyPlugin
      ---@param opts MasonSettings|{ensure_installed?: string[]}
      opts = function(_, opts)
        local packages = vim.tbl_values(require('util.formatters').packages)
        -- These tools are installed when their filetypes are opened.
        opts.ensure_installed = vim
          .iter(opts.ensure_installed or {})
          :filter(
            ---@param package_name string
            ---@return boolean
            function(package_name) return not vim.tbl_contains(packages, package_name) end
          )
          :totable()
      end,
    },
  },
  ---@param _ LazyPlugin
  ---@param opts conform.setupOpts
  opts = function(_, opts)
    opts.formatters_by_ft = vim.tbl_deep_extend('force', opts.formatters_by_ft or {}, {
      go = { 'goimports', 'gofmt' },
      rust = { 'rustfmt' },
    })
    vim.iter(prettier_filetypes):each(
      ---@param filetype string
      function(filetype)
        -- Keep the Markdown cleanup chain supplied by LazyVim.
        opts.formatters_by_ft[filetype] = opts.formatters_by_ft[filetype] or { 'prettier' }
      end
    )
    vim.iter(biome_filetypes):each(
      ---@param filetype string
      function(filetype) opts.formatters_by_ft[filetype] = web_formatters end
    )
    opts.formatters = vim.tbl_deep_extend('force', opts.formatters or {}, {
      ['biome-check'] = { require_cwd = true },
      prettier = { options = { ft_parsers = { htmlangular = 'angular' } } },
    })
    require('util.formatters').setup()
  end,
}
