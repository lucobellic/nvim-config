return {
  'mrcjkb/rustaceanvim',
  opts = function(_, opts)
    local timer = vim.uv.new_timer()
    local debounce_ms = 1000

    vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
      group = vim.api.nvim_create_augroup('rust', { clear = true }),
      pattern = { '*.rs' },
      callback = function()
        if timer then
          timer:stop()
          timer:start(debounce_ms, 0, vim.schedule_wrap(vim.cmd.RustLsp({ 'flyCheck', 'run' })))
        end
      end,
      desc = 'Run Rust flyCheck after delay',
    })

    return vim.tbl_deep_extend('force', opts or {}, {
      tools = {
        float_win_config = { border = vim.g.border.style },
      },
    })
  end,
}
