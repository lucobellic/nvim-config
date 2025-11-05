return {
  'rachartier/tiny-glimmer.nvim',
  cond = false, -- not functional yet
  event = 'VeryLazy',
  priority = 10, -- Needs to be a really low priority, to catch others plugins keybindings.
  opts = {
    enabled = true,
    disable_warnings = true,
    refresh_interval_ms = 20,
    overwrite = {
      -- Automatically map keys to overwrite operations
      -- If set to false, you will need to call the API functions to trigger the animations
      -- WARN: You should disable this if you have already mapped these keys
      --        or if you want to use the API functions to trigger the animations
      auto_map = true,
      yank = {
        enabled = true,
        default_animation = 'reverse_fade',
      },
      search = { enabled = false },
      paste = {
        enabled = true,
        from_color = 'DiffAdd',
        to_color = 'DiffAdd',
        default_animation = 'reverse_fade',
      },
      undo = {
        enabled = true,
        default_animation = {
          name = 'fade',
          settings = {
            from_color = 'DiffDelete',
          },
        },
        undo_mapping = 'u',
      },
      redo = {
        enabled = true,
        default_animation = {
          name = 'fade',
          settings = {
            from_color = 'DiffAdd',
          },
        },
        redo_mapping = '<c-r>',
      },
    },

    support = { substitute = { enabled = false } },

    presets = {
      -- Enable animation on cursorline when an event in `on_events` is triggered
      -- Similar to `pulsar.el`
      pulsar = {
        enabled = false,
        on_events = { 'WinEnter' },
        default_animation = {
          name = 'fade',
          settings = {
            max_duration = 200,
            min_duration = 200,
            from_color = 'Normal',
            to_color = 'CursorLine',
          },
        },
      },
    },

    -- Only use if you have a transparent background
    -- It will override the highlight group background color for `to_color` in all animations
    transparency_color = true, -- nil,
    -- Animation configurations
    animations = {
      fade = {
        max_duration = 500,
        min_duration = 500,
      },
      reverse_fade = {
        max_duration = 500,
        min_duration = 500,
        easing = 'outBack',
      },
      hijack_ft_disabled = {
        'alpha',
        'snacks_dashboard',
      },
    },
    virt_text = {
      priority = 2048,
    },
  },
}
