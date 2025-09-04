--- Find the first CMakeLists.txt file in the given path or its parent directories
---@param path? string The starting path to search from or current file's directory if nil
local function find_closest_cmake_lists(path)
  local path = path or vim.fn.expand('%:p:h')
  return vim.fs.find({ 'CMakeLists.txt' }, { path = path, upward = true, limit = 1 })[1]
end

local function jump_to_cmake_lists()
  local cmake_file = find_closest_cmake_lists()
  if cmake_file then
    vim.cmd('edit ' .. cmake_file)
  else
    vim.notify(
      'No CMakeLists.txt found in the current directory or its parents.',
      vim.log.levels.INFO,
      { title = 'CMake' }
    )
  end
end

return {
  'Civitasv/cmake-tools.nvim',
  init = function() end,
  cmd = {
    'CMakeRun',
    'CMakeBuild',
    'CMakeClean',
    'CMakeDebug',
    'CMakeInstall',
    'CMakeRunTest',
    'CMakeGenerate',
    'CMakeQuickRun',
    'CMakeSettings',
    'CMakeSelectCwd',
    'CMakeSelectKit',
    'CMakeLaunchArgs',
    'CMakeOpenRunner',
    'CMakeQuickBuild',
    'CMakeQuickDebug',
    'CMakeQuickStart',
    'CMakeStopRunner',
    'CMakeBuildTarget',
    'CMakeCloseRunner',
    'CMakeOpenExecutor',
    'CMakeStopExecutor',
    'CMakeCloseExecutor',
    'CMakeRunCurrentFile',
    'CMakeSelectBuildDir',
    'CMakeTargetSettings',
    'CMakeSelectBuildType',
    'CMakeShowTargetFiles',
    'CMakeBuildCurrentFile',
    'CMakeClearTargetCache',
    'CMakeDebugCurrentFile',
    'CMakeSelectBuildPreset',
    'CMakeSelectBuildTarget',
    'CMakeSelectLaunchTarget',
    'CMakeSelectConfigurePreset',
  },
  keys = {
    { '<leader>oc', jump_to_cmake_lists, desc = 'Jump to CMakeLists.txt' },
  },
  opts = {
    cmake_executor = {
      name = 'overseer',
    },
    cmake_virtual_text_support = false,
    cmake_notifications = {
      runner = { enabled = false },
      executor = { enabled = false },
    },
  },
}
