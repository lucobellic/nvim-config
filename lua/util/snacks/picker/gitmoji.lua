---@module 'snacks.picker'

local M = {}

--- Full gitmoji list sourced from https://gitmoji.dev/api/gitmojis
---@type { emoji: string, code: string, description: string, name: string, semver: string|nil }[]
local GITMOJIS = {
  {
    emoji = '🎨',
    code = ':art:',
    description = 'Improve structure / format of the code.',
    name = 'art',
    semver = nil,
  },
  { emoji = '⚡️', code = ':zap:', description = 'Improve performance.', name = 'zap', semver = 'patch' },
  { emoji = '🔥', code = ':fire:', description = 'Remove code or files.', name = 'fire', semver = nil },
  { emoji = '🐛', code = ':bug:', description = 'Fix a bug.', name = 'bug', semver = 'patch' },
  { emoji = '🚑️', code = ':ambulance:', description = 'Critical hotfix.', name = 'ambulance', semver = 'patch' },
  { emoji = '✨', code = ':sparkles:', description = 'Introduce new features.', name = 'sparkles', semver = 'minor' },
  { emoji = '📝', code = ':memo:', description = 'Add or update documentation.', name = 'memo', semver = nil },
  { emoji = '🚀', code = ':rocket:', description = 'Deploy stuff.', name = 'rocket', semver = nil },
  {
    emoji = '💄',
    code = ':lipstick:',
    description = 'Add or update the UI and style files.',
    name = 'lipstick',
    semver = 'patch',
  },
  { emoji = '🎉', code = ':tada:', description = 'Begin a project.', name = 'tada', semver = nil },
  {
    emoji = '✅',
    code = ':white_check_mark:',
    description = 'Add, update, or pass tests.',
    name = 'white-check-mark',
    semver = nil,
  },
  {
    emoji = '🔒️',
    code = ':lock:',
    description = 'Fix security or privacy issues.',
    name = 'lock',
    semver = 'patch',
  },
  {
    emoji = '🔐',
    code = ':closed_lock_with_key:',
    description = 'Add or update secrets.',
    name = 'closed-lock-with-key',
    semver = nil,
  },
  { emoji = '🔖', code = ':bookmark:', description = 'Release / Version tags.', name = 'bookmark', semver = nil },
  {
    emoji = '🚨',
    code = ':rotating_light:',
    description = 'Fix compiler / linter warnings.',
    name = 'rotating-light',
    semver = nil,
  },
  { emoji = '🚧', code = ':construction:', description = 'Work in progress.', name = 'construction', semver = nil },
  { emoji = '💚', code = ':green_heart:', description = 'Fix CI Build.', name = 'green-heart', semver = nil },
  {
    emoji = '⬇️',
    code = ':arrow_down:',
    description = 'Downgrade dependencies.',
    name = 'arrow-down',
    semver = 'patch',
  },
  { emoji = '⬆️', code = ':arrow_up:', description = 'Upgrade dependencies.', name = 'arrow-up', semver = 'patch' },
  {
    emoji = '📌',
    code = ':pushpin:',
    description = 'Pin dependencies to specific versions.',
    name = 'pushpin',
    semver = 'patch',
  },
  {
    emoji = '👷',
    code = ':construction_worker:',
    description = 'Add or update CI build system.',
    name = 'construction-worker',
    semver = nil,
  },
  {
    emoji = '📈',
    code = ':chart_with_upwards_trend:',
    description = 'Add or update analytics or track code.',
    name = 'chart-with-upwards-trend',
    semver = 'patch',
  },
  { emoji = '♻️', code = ':recycle:', description = 'Refactor code.', name = 'recycle', semver = nil },
  {
    emoji = '➕',
    code = ':heavy_plus_sign:',
    description = 'Add a dependency.',
    name = 'heavy-plus-sign',
    semver = 'patch',
  },
  {
    emoji = '➖',
    code = ':heavy_minus_sign:',
    description = 'Remove a dependency.',
    name = 'heavy-minus-sign',
    semver = 'patch',
  },
  {
    emoji = '🔧',
    code = ':wrench:',
    description = 'Add or update configuration files.',
    name = 'wrench',
    semver = 'patch',
  },
  {
    emoji = '🔨',
    code = ':hammer:',
    description = 'Add or update development scripts.',
    name = 'hammer',
    semver = nil,
  },
  {
    emoji = '🌐',
    code = ':globe_with_meridians:',
    description = 'Internationalization and localization.',
    name = 'globe-with-meridians',
    semver = 'patch',
  },
  { emoji = '✏️', code = ':pencil2:', description = 'Fix typos.', name = 'pencil2', semver = 'patch' },
  {
    emoji = '💩',
    code = ':poop:',
    description = 'Write bad code that needs to be improved.',
    name = 'poop',
    semver = nil,
  },
  { emoji = '⏪️', code = ':rewind:', description = 'Revert changes.', name = 'rewind', semver = 'patch' },
  {
    emoji = '🔀',
    code = ':twisted_rightwards_arrows:',
    description = 'Merge branches.',
    name = 'twisted-rightwards-arrows',
    semver = nil,
  },
  {
    emoji = '📦️',
    code = ':package:',
    description = 'Add or update compiled files or packages.',
    name = 'package',
    semver = 'patch',
  },
  {
    emoji = '👽️',
    code = ':alien:',
    description = 'Update code due to external API changes.',
    name = 'alien',
    semver = 'patch',
  },
  {
    emoji = '🚚',
    code = ':truck:',
    description = 'Move or rename resources (e.g.: files, paths, routes).',
    name = 'truck',
    semver = nil,
  },
  {
    emoji = '📄',
    code = ':page_facing_up:',
    description = 'Add or update license.',
    name = 'page-facing-up',
    semver = nil,
  },
  { emoji = '💥', code = ':boom:', description = 'Introduce breaking changes.', name = 'boom', semver = 'major' },
  { emoji = '🍱', code = ':bento:', description = 'Add or update assets.', name = 'bento', semver = 'patch' },
  {
    emoji = '♿️',
    code = ':wheelchair:',
    description = 'Improve accessibility.',
    name = 'wheelchair',
    semver = 'patch',
  },
  {
    emoji = '💡',
    code = ':bulb:',
    description = 'Add or update comments in source code.',
    name = 'bulb',
    semver = nil,
  },
  { emoji = '🍻', code = ':beers:', description = 'Write code drunkenly.', name = 'beers', semver = nil },
  {
    emoji = '💬',
    code = ':speech_balloon:',
    description = 'Add or update text and literals.',
    name = 'speech-balloon',
    semver = 'patch',
  },
  {
    emoji = '🗃️',
    code = ':card_file_box:',
    description = 'Perform database related changes.',
    name = 'card-file-box',
    semver = 'patch',
  },
  { emoji = '🔊', code = ':loud_sound:', description = 'Add or update logs.', name = 'loud-sound', semver = nil },
  { emoji = '🔇', code = ':mute:', description = 'Remove logs.', name = 'mute', semver = nil },
  {
    emoji = '👥',
    code = ':busts_in_silhouette:',
    description = 'Add or update contributor(s).',
    name = 'busts-in-silhouette',
    semver = nil,
  },
  {
    emoji = '🚸',
    code = ':children_crossing:',
    description = 'Improve user experience / usability.',
    name = 'children-crossing',
    semver = 'patch',
  },
  {
    emoji = '🏗️',
    code = ':building_construction:',
    description = 'Make architectural changes.',
    name = 'building-construction',
    semver = nil,
  },
  { emoji = '📱', code = ':iphone:', description = 'Work on responsive design.', name = 'iphone', semver = 'patch' },
  { emoji = '🤡', code = ':clown_face:', description = 'Mock things.', name = 'clown-face', semver = nil },
  { emoji = '🥚', code = ':egg:', description = 'Add or update an easter egg.', name = 'egg', semver = 'patch' },
  {
    emoji = '🙈',
    code = ':see_no_evil:',
    description = 'Add or update a .gitignore file.',
    name = 'see-no-evil',
    semver = nil,
  },
  {
    emoji = '📸',
    code = ':camera_flash:',
    description = 'Add or update snapshots.',
    name = 'camera-flash',
    semver = nil,
  },
  { emoji = '⚗️', code = ':alembic:', description = 'Perform experiments.', name = 'alembic', semver = 'patch' },
  { emoji = '🔍️', code = ':mag:', description = 'Improve SEO.', name = 'mag', semver = 'patch' },
  { emoji = '🏷️', code = ':label:', description = 'Add or update types.', name = 'label', semver = 'patch' },
  { emoji = '🌱', code = ':seedling:', description = 'Add or update seed files.', name = 'seedling', semver = nil },
  {
    emoji = '🚩',
    code = ':triangular_flag_on_post:',
    description = 'Add, update, or remove feature flags.',
    name = 'triangular-flag-on-post',
    semver = 'patch',
  },
  { emoji = '🥅', code = ':goal_net:', description = 'Catch errors.', name = 'goal-net', semver = 'patch' },
  {
    emoji = '💫',
    code = ':dizzy:',
    description = 'Add or update animations and transitions.',
    name = 'dizzy',
    semver = 'patch',
  },
  {
    emoji = '🗑️',
    code = ':wastebasket:',
    description = 'Deprecate code that needs to be cleaned up.',
    name = 'wastebasket',
    semver = 'patch',
  },
  {
    emoji = '🛂',
    code = ':passport_control:',
    description = 'Work on code related to authorization, roles and permissions.',
    name = 'passport-control',
    semver = 'patch',
  },
  {
    emoji = '🩹',
    code = ':adhesive_bandage:',
    description = 'Simple fix for a non-critical issue.',
    name = 'adhesive-bandage',
    semver = 'patch',
  },
  {
    emoji = '🧐',
    code = ':monocle_face:',
    description = 'Data exploration/inspection.',
    name = 'monocle-face',
    semver = nil,
  },
  { emoji = '⚰️', code = ':coffin:', description = 'Remove dead code.', name = 'coffin', semver = nil },
  { emoji = '🧪', code = ':test_tube:', description = 'Add a failing test.', name = 'test-tube', semver = nil },
  {
    emoji = '👔',
    code = ':necktie:',
    description = 'Add or update business logic.',
    name = 'necktie',
    semver = 'patch',
  },
  {
    emoji = '🩺',
    code = ':stethoscope:',
    description = 'Add or update healthcheck.',
    name = 'stethoscope',
    semver = nil,
  },
  { emoji = '🧱', code = ':bricks:', description = 'Infrastructure related changes.', name = 'bricks', semver = nil },
  {
    emoji = '🧑‍💻',
    code = ':technologist:',
    description = 'Improve developer experience.',
    name = 'technologist',
    semver = nil,
  },
  {
    emoji = '💸',
    code = ':money_with_wings:',
    description = 'Add sponsorships or money related infrastructure.',
    name = 'money-with-wings',
    semver = nil,
  },
  {
    emoji = '🧵',
    code = ':thread:',
    description = 'Add or update code related to multithreading or concurrency.',
    name = 'thread',
    semver = nil,
  },
  {
    emoji = '🦺',
    code = ':safety_vest:',
    description = 'Add or update code related to validation.',
    name = 'safety-vest',
    semver = nil,
  },
  { emoji = '✈️', code = ':airplane:', description = 'Improve offline support.', name = 'airplane', semver = nil },
  {
    emoji = '🦖',
    code = ':t-rex:',
    description = 'Code that adds backwards compatibility.',
    name = 't-rex',
    semver = nil,
  },
}

--- Build picker items from the gitmoji list.
--- Each item exposes the emoji, code and description for fuzzy matching.
---@return snacks.picker.finder.Item[]
local function build_items()
  return vim
    .iter(ipairs(GITMOJIS))
    :map(function(i, gm)
      local semver_badge = gm.semver and (' [' .. gm.semver .. ']') or ''
      return {
        idx = i,
        score = 0,
        -- text is used by the fuzzy matcher; include all searchable fields
        text = gm.emoji .. ' ' .. gm.name .. ' ' .. gm.code .. ' ' .. gm.description,
        emoji = gm.emoji,
        code = gm.code,
        description = gm.description,
        name = gm.name,
        semver = gm.semver,
        semver_badge = semver_badge,
      }
    end)
    :totable()
end

--- Format a gitmoji picker item for display in the list.
---@param item snacks.picker.Item
---@return snacks.picker.Highlight[]
local function format_gitmoji(item)
  ---@type snacks.picker.Highlight[]
  return {
    { item.emoji .. ' ', 'SnacksPickerSpecial' },
    { item.code .. ' ', 'SnacksPickerLabel' },
    { item.description, 'SnacksPickerComment' },
    {
      item.semver_badge,
      item.semver == 'major' and 'DiagnosticError' or item.semver == 'minor' and 'DiagnosticWarn' or 'DiagnosticHint',
    },
  }
end

--- Preview handler: show gitmoji details in the preview window.
---@param ctx snacks.picker.preview.ctx
local function preview_gitmoji(ctx)
  local item = ctx.item
  local lines = {
    '  ' .. item.emoji .. '  ' .. item.name,
    '',
    'Code:        ' .. item.code,
    'Description: ' .. item.description,
    'Semver:      ' .. (item.semver or 'none'),
  }
  local buf = ctx.preview:scratch()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = 'markdown'
end

--- Confirm action: insert the emoji + code at cursor / into command line.
---@param picker snacks.Picker
---@param item snacks.picker.Item
local function confirm_gitmoji(picker, item)
  picker:close()
  if not item then
    return
  end
  local insert = item.emoji .. ' '
  -- Put into the default register and insert at cursor
  vim.fn.setreg('"', insert)
  vim.schedule(function()
    local mode = vim.api.nvim_get_mode().mode
    local after = mode ~= 'i' and mode ~= 'ic'
    vim.api.nvim_put({ insert }, 'c', after, true)
  end)
end

--- Open the gitmoji picker.
function M.pick()
  Snacks.picker.pick({
    source = 'gitmoji',
    title = 'Gitmoji',
    items = build_items(),
    format = format_gitmoji,
    preview = preview_gitmoji,
    confirm = confirm_gitmoji,
  })
end

return M
