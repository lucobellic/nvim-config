return {
  'tiagovla/scope.nvim',
  event = 'VeryLazy',
  config = function()
    require('scope').setup({ restore_state = true })
  end
}
