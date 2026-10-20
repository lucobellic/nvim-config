---@param name string
---@param command string[]
---@param directory string
---@return overseer.TemplateDefinition
local function make_template(name, command, directory)
  return {
    name = name,
    ---@return overseer.TaskDefinition
    builder = function() return { cmd = command, cwd = directory } end,
  }
end

---@type overseer.TemplateFileProvider
return {
  ---@param opts overseer.SearchParams
  ---@param callback fun(result: string|overseer.TemplateDefinition[])
  ---@return string|overseer.TemplateDefinition[]|nil
  generator = function(opts, callback)
    if vim.fn.executable('cmake') == 0 then
      return 'Command "cmake" not found'
    end

    local project = vim.fs.find({ 'CMakePresets.json', 'CMakeLists.txt' }, {
      path = opts.dir,
      upward = true,
      type = 'file',
    })[1]
    if not project then
      return 'No CMake project found'
    end

    local directory = vim.fs.dirname(project)
    local build_directory = 'build'
    if vim.fn.isdirectory(directory .. '/build') == 0 and vim.fn.isdirectory(directory .. '/../build') == 1 then
      build_directory = '../build'
    end

    ---@type overseer.TemplateDefinition[]
    local templates = {
      make_template('cmake configure', { 'cmake', '-S', '.', '-B', build_directory }, directory),
      make_template('cmake build', { 'cmake', '--build', build_directory }, directory),
    }
    if vim.fn.filereadable(directory .. '/CMakePresets.json') == 0 then
      return templates
    end

    vim.system(
      { 'cmake', '--list-presets=all' },
      { cwd = directory, text = true, env = { LANG = 'C', LC_ALL = 'C' } },
      vim.schedule_wrap(
        ---@param result vim.SystemCompleted
        function(result)
          if result.code ~= 0 then
            callback(result.stderr and result.stderr ~= '' and result.stderr or 'Unable to list CMake presets')
            return
          end

          ---@type string?
          local preset_type
          vim.iter(vim.gsplit(result.stdout or '', '\n')):each(
            ---@param line string
            function(line)
              local section = line:match('^Available (%w+) presets:')
              if section then
                preset_type = section
                return
              end

              local preset = line:match('^%s+"([^"]+)"')
              if preset and (preset_type == 'configure' or preset_type == 'build') then
                local command = preset_type == 'build' and { 'cmake', '--build', '--preset', preset }
                  or { 'cmake', '--preset', preset }
                table.insert(
                  templates,
                  make_template('cmake ' .. preset_type .. ' --preset ' .. preset, command, directory)
                )
              end
            end
          )
          callback(templates)
        end
      )
    )
  end,
}
