local biome_supported = {
  'css',
  'graphql',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'svelte',
  'typescript',
  'typescriptreact',
  'vue',
}

return {
  'stevearc/conform.nvim',
  dependencies = {
    {
      'mason-org/mason.nvim',
      optional = true,
      opts = { ensure_installed = { 'biome' } },
    },
  },
  ---@param opts conform.setupOpts
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs(biome_supported) do
      opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
      ---@cast opts.formatters_by_ft[ft] string[]
      table.insert(opts.formatters_by_ft[ft], 1, 'biome-check')
      opts.formatters_by_ft[ft].stop_after_first = true
    end
    opts.formatters = opts.formatters or {}
    opts.formatters['biome-check'] = {
      require_cwd = true,
    }
  end,
}
