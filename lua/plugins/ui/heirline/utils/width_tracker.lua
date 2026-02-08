-- Centralized width tracking for dynamic statusline alignment.
-- Each left component calls `add()` during its `init()`.
-- The first component (ViMode) calls `reset()` to start fresh each evaluation cycle.
-- LeftAlignment calls `get()` to retrieve the accumulated width.

local M = {}

M.left_width = 0

function M.reset() M.left_width = 0 end

function M.add(text)
  if text and text ~= '' then
    M.left_width = M.left_width + vim.api.nvim_eval_statusline(text, {}).width
  end
end

function M.get() return M.left_width end

return M
