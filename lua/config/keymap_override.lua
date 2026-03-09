local keymap_set = vim.keymap.set

---@alias RepeatKey '.' | ',' | ';'
---@alias RepeatFn fun(...): any

---Descriptor produced by `_normalise_repeatable`.
---Each field holds the callback to invoke when that key triggers a repeat,
---or `nil` when that key should not be handled by this keymap.
---@class RepeatDesc
---@field dot      RepeatFn|nil  Callback invoked on `.` (dot-repeat via operatorfunc)
---@field forward  RepeatFn|nil  Callback invoked on `;`
---@field backward RepeatFn|nil  Callback invoked on `,`

---State tracking the last motion-repeat pair so `;` / `,` know what to call.
---@class MotionState
---@field forward  RepeatFn|nil
---@field backward RepeatFn|nil

---Accepted shapes for the `repeatable` keymap option:
---  • `true`                          dot-repeat only, uses `rhs`
---  • `'.'`                           dot-repeat only, uses `rhs`
---  • `';'`                           forward (`;`) only, uses `rhs`
---  • `','`                           forward + backward (`;`/`,`), uses `rhs`
---  • `{ '.' }`                       dot-repeat only, uses `rhs`
---  • `{ '.', [','] = fn }`           dot=rhs, backward=fn
---  • `{ '.', [';'] = fn }`           dot=rhs, forward=fn
---  • `{ ['.'] = fn, [','] = fn2 }`   explicit per-key overrides
---  Mixed positional + keyed is allowed; an explicit function always wins over `rhs`.
---@alias RepeatableOpt boolean | RepeatKey | { [1]: RepeatKey?, [2]: RepeatKey?, ['.']: RepeatFn?, [',']: RepeatFn?, [';']: RepeatFn? }

-- Global table holding operatorfunc callbacks, keyed by unique slot names.
-- Must be global so "v:lua.__keymap_repeat_fns.fnN" is resolvable by Neovim.
_G.__keymap_repeat_fns = _G.__keymap_repeat_fns or {}

---@type MotionState|nil
local _last_motion = nil

-- Monotonic counter used to generate unique slot names.
local _repeat_id = 0

---Return a new unique slot name for `_G.__keymap_repeat_fns`.
---@return string
local function _next_slot()
  _repeat_id = _repeat_id + 1
  return 'fn' .. _repeat_id
end

---Ensure `rhs` is callable. String keysequences are wrapped in a feedkeys call
---so that `operatorfunc` can invoke them.
---@param rhs string|fun(...): any
---@return fun(...): any
local function _callable(rhs)
  if type(rhs) == 'function' then
    return rhs
  end
  return function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(rhs, true, false, true), 'n', false) end
end

---Normalise `repeatable` into a `RepeatDesc`.
---`rhs` is the keymap's own action and is used as the fallback for any key
---listed positionally in the table form (i.e. without an explicit function).
---Returns `nil` when `repeatable` is an unrecognised value.
---@param repeatable RepeatableOpt
---@param rhs string|fun(...): any
---@return RepeatDesc|nil
local function _normalise_repeatable(repeatable, rhs)
  local base = _callable(rhs)

  -- Shorthand scalar forms
  if repeatable == true or repeatable == '.' then
    return { dot = base, forward = nil, backward = nil }
  end
  if repeatable == ';' then
    return { dot = nil, forward = base, backward = nil }
  end
  if repeatable == ',' then
    return { dot = nil, forward = base, backward = base }
  end

  -- Table form: positional entries name keys that should fall back to `base`;
  -- string-keyed entries supply explicit override functions.
  if type(repeatable) == 'table' then
    ---@type table<RepeatKey, true>
    local use_base = {}
    for _, v in ipairs(repeatable) do
      use_base[v] = true
    end

    ---Return the callback for `key`: explicit function > positional fallback > nil.
    ---@param key RepeatKey
    ---@return RepeatFn|nil
    local function resolve(key)
      if type(repeatable[key]) == 'function' then
        return repeatable[key]
      end
      if use_base[key] then
        return base
      end
      return nil
    end

    return {
      dot = resolve('.'),
      forward = resolve(';'),
      backward = resolve(','),
    }
  end

  return nil
end

---Store `callback` under `slot` in the global operatorfunc table and return an
---`expr = true` wrapper. When the wrapper runs it sets `operatorfunc` to the slot
---and returns `"g@l"`, triggering the callback. On subsequent dot-repeats Neovim
---calls the slot directly, bypassing this wrapper entirely.
---@param callback fun(): any
---@param slot string
---@return fun(): string
local function _make_opfunc_wrapper(callback, slot)
  _G.__keymap_repeat_fns[slot] = callback
  return function()
    vim.go.operatorfunc = 'v:lua.__keymap_repeat_fns.' .. slot
    return 'g@l'
  end
end

---Install module-level `;` and `,` overrides that delegate to `_last_motion` when
---a motion-repeatable keymap has been used, falling back to the native `f`/`F`/`t`/`T`
---`;` / `,` behaviour otherwise.
local function _install_motion_repeat_keys()
  local native_fwd = vim.api.nvim_replace_termcodes(';', true, false, true)
  local native_bwd = vim.api.nvim_replace_termcodes(',', true, false, true)

  ---Repeat the last custom forward motion, or fall back to native `;`.
  local function forward()
    if _last_motion and _last_motion.forward then
      _last_motion.forward()
    else
      vim.api.nvim_feedkeys(native_fwd, 'n', false)
    end
  end

  ---Repeat the last custom backward motion, or fall back to native `,`.
  local function backward()
    if _last_motion and _last_motion.backward then
      _last_motion.backward()
    else
      vim.api.nvim_feedkeys(native_bwd, 'n', false)
    end
  end

  for _, mode in ipairs({ 'n', 'x', 'o' }) do
    keymap_set(mode, ';', forward, { silent = true, desc = 'Repeat last custom motion (forward)' })
    keymap_set(mode, ',', backward, { silent = true, desc = 'Repeat last custom motion (backward)' })
  end
end

_install_motion_repeat_keys()

---Extended `vim.keymap.set` that adds a `repeatable` option.
---All standard `vim.keymap.set` options are forwarded unchanged.
---When `repeatable` is present the keymap is wrapped so that:
---  • `.` re-executes the action natively via `operatorfunc` / `g@l` (no plugin needed),
---    **only** when `'.'` is included in the `repeatable` spec.
---  • `;` / `,` re-execute their respective callbacks when the keymap was last used.
---    When only `','` or `';'` are specified, dot-repeat is intentionally left unregistered.
---@param mode string|string[]
---@param lhs string
---@param rhs string|fun(...): any
---@param opts? vim.keymap.set.Opts & { repeatable?: RepeatableOpt }
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false

  local repeatable = opts.repeatable
  if repeatable ~= nil then
    ---@diagnostic disable-next-line: inject-field
    opts.repeatable = nil

    local desc = _normalise_repeatable(repeatable, rhs)
    if desc then
      local has_motion = desc.forward ~= nil or desc.backward ~= nil
      assert(
        desc.dot ~= nil or has_motion,
        'repeatable: at least one of ".", ";", "," must be specified'
      )

      if desc.dot ~= nil then
        -- Dot-repeat path: register via operatorfunc / g@l so that `.` replays the action.
        -- Also refreshes `_last_motion` when motion keys are part of the spec.
        ---@param callback fun(): any  Operatorfunc slot: updates _last_motion then runs desc.dot.
        local function opfunc_callback()
          if has_motion then
            _last_motion = { forward = desc.forward, backward = desc.backward }
          end
          desc.dot()
        end

        local slot = _next_slot()
        local wrapper = _make_opfunc_wrapper(opfunc_callback, slot)
        return keymap_set(mode, lhs, wrapper, vim.tbl_extend('force', opts, { expr = true }))
      else
        -- Motion-only path: `'.'` was not requested, so do NOT register operatorfunc.
        -- The keymap runs `rhs` normally but updates `_last_motion` so `;` / `,` work.
        local base = _callable(rhs)
        local function motion_only_callback()
          _last_motion = { forward = desc.forward, backward = desc.backward }
          base()
        end
        return keymap_set(mode, lhs, motion_only_callback, opts)
      end
    end
  end

  return keymap_set(mode, lhs, rhs, opts)
end
