local should_profile = os.getenv('NVIM_PROFILE')
local nvim_start_profile = should_profile and should_profile:lower():match('^start')

return {
  'stevearc/profile.nvim',
  lazy = not nvim_start_profile,
  keys = {
    {
      '<f1>',
      function()
        if os.getenv('NVIM_PROFILE') then
          local prof = require('profile')
          if prof.is_recording() then
            prof.stop()
            vim.ui.input(
              { prompt = 'Save profile to:', completion = 'file', default = 'profile.json' },
              function(filename)
                if filename then
                  prof.export(filename)
                  vim.notify(string.format('Wrote %s', filename))
                end
              end
            )
          else
            prof.start('*')
          end
        end
      end,
      desc = 'Toggle profile',
    },
  },
  config = function()
    if should_profile then
      require('profile').instrument_autocmds()
      if nvim_start_profile then
        require('profile').start('*')
      else
        require('profile').instrument('*')
      end
    end
  end,
}
