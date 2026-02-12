---@module 'snacks.picker'

local M = {}

--- Resolve the first existing branch from a list of candidates.
--- Checks both local and remote (origin/) branches.
--- @param candidates string[]
--- @param cwd? string
--- @return string|nil
function M.resolve_base_branch(candidates, cwd)
  for _, branch in ipairs(candidates) do
    -- check local branch
    vim.fn.systemlist({ 'git', '-C', cwd or '.', 'rev-parse', '--verify', '--quiet', branch })
    if vim.v.shell_error == 0 then
      return branch
    end
    -- check remote branch
    local remote = 'origin/' .. branch
    vim.fn.systemlist({ 'git', '-C', cwd or '.', 'rev-parse', '--verify', '--quiet', remote })
    if vim.v.shell_error == 0 then
      return remote
    end
  end
  return nil
end

--- Build git diff command arguments.
--- @param base? string Base branch/commit for comparison
--- @return string[] args Git command arguments
local function build_diff_args(base)
  local args = { '-c', 'core.quotepath=false', '--no-pager', 'diff', '--no-color', '--no-ext-diff', '-U3' }
  if base then
    vim.list_extend(args, { '--merge-base', base })
  end
  return args
end

--- Collect raw diff blocks from git diff output.
--- Executes git diff with the given arguments and parses the output into blocks.
--- @param ctx snacks.picker.finder.ctx Picker context
--- @param cwd string Working directory
--- @param base_args string[] Base git diff arguments
--- @param extra_args string[] Additional arguments (e.g., --cached)
--- @param is_staged boolean Whether this is for staged changes
--- @return { block: snacks.picker.diff.Block, staged: boolean }[]
local function collect_diff_blocks(ctx, cwd, base_args, extra_args, is_staged)
  local all_args = vim.list_extend(vim.deepcopy(base_args), extra_args)
  local lines = {} ---@type string[]
  require('snacks.picker.source.proc').proc(
    ctx:opts({
      cmd = 'git',
      args = all_args,
      cwd = cwd,
    }),
    ctx
  )(function(item) lines[#lines + 1] = item.text end)

  local parsed = require('snacks.picker.source.diff').parse(lines)
  ---@type { block: snacks.picker.diff.Block, staged: boolean }[]
  local result = vim.iter(parsed.blocks):map(function(block) return { block = block, staged = is_staged } end):totable()
  return result
end

--- Extract searchable content lines from a diff block.
--- Filters lines based on the include mode (changes/additions/deletions).
--- @param block snacks.picker.diff.Block Diff block to extract from
--- @param include 'changes'|'all'|'additions'|'deletions' What content to include
--- @return string[]
local function extract_block_content(block, include)
  local content_lines = {} ---@type string[]
  for _, hunk in ipairs(block.hunks) do
    for i = 2, #hunk.diff do
      local raw = hunk.diff[i]
      local prefix = raw:sub(1, 1)
      local line_content = raw:sub(2)

      local dominated = (include == 'additions' and prefix ~= '+')
        or (include == 'deletions' and prefix ~= '-')
        or (include == 'changes' and prefix ~= '+' and prefix ~= '-')

      if not dominated then
        content_lines[#content_lines + 1] = line_content
      end
    end
  end
  return content_lines
end

--- Check if text contains the search term using smart case matching.
--- @param text string Text to search in
--- @param search string Search term
--- @return boolean
local function text_matches_search(text, search)
  local words = vim.split(search, '%s+')
  return vim
    .iter(words)
    :map(function(word) return vim.trim(word) end)
    :filter(function(word) return word ~= '' end)
    :all(function(word)
      local ignore_case = word == word:lower()
      local haystack = ignore_case and text:lower() or text
      local needle = ignore_case and word:lower() or word
      return haystack:find(needle, 1, true) ~= nil
    end)
end

--- Group diff blocks by file and track metadata.
--- @param blocks { block: snacks.picker.diff.Block, staged: boolean }[] All diff blocks
--- @return table<string, { blocks: { block: snacks.picker.diff.Block, staged: boolean }[], first_line: number }> by_file
--- @return string[] file_order Sorted list of file paths
local function group_blocks_by_file(blocks)
  ---@type table<string, { blocks: { block: snacks.picker.diff.Block, staged: boolean }[], first_line: number }>
  local by_file = {}
  local file_order = {} ---@type string[]

  for _, entry in ipairs(blocks) do
    local file = entry.block.file
    if not by_file[file] then
      by_file[file] = { blocks = {}, first_line = math.huge }
      file_order[#file_order + 1] = file
    end
    by_file[file].blocks[#by_file[file].blocks + 1] = entry
    local fl = entry.block.hunks[1] and entry.block.hunks[1].line or 1
    if fl < by_file[file].first_line then
      by_file[file].first_line = fl
    end
  end

  table.sort(file_order)
  return by_file, file_order
end

--- Build combined diff string for preview from file's blocks.
--- @param blocks { block: snacks.picker.diff.Block, staged: boolean }[] Blocks for a single file
--- @return string diff_string Combined diff for preview
--- @return boolean has_staged Whether any block is staged
--- @return snacks.picker.diff.Block first_block First block for metadata
local function build_file_diff(blocks)
  local diff_parts = {} ---@type string[]
  local has_staged = false
  local first_block = blocks[1].block

  for _, entry in ipairs(blocks) do
    if entry.staged then
      has_staged = true
    end
    local hunk_diff = vim.list_extend(vim.deepcopy(entry.block.header), {})
    for _, hunk in ipairs(entry.block.hunks) do
      vim.list_extend(hunk_diff, hunk.diff)
    end
    diff_parts[#diff_parts + 1] = table.concat(hunk_diff, '\n')
  end

  return table.concat(diff_parts, '\n'), has_staged, first_block
end

--- Format a picker item with git status indicators.
--- @param item snacks.picker.finder.Item Item to format
--- @param picker snacks.Picker Picker instance
--- @return snacks.picker.Highlight[]
local function format_diff_item(item, picker)
  local ret = {} ---@type snacks.picker.Highlight[]

  -- staged indicator
  if item.staged then
    ret[#ret + 1] = { 'S ', 'SnacksPickerGitStatusStaged', virtual = true }
  else
    ret[#ret + 1] = { '  ', virtual = true }
  end

  -- Derive a git-status-like indicator from the block metadata
  local block = item.block ---@type snacks.picker.diff.Block
  local status = block.new and 'A' or block.delete and 'D' or block.rename and 'R' or block.copy and 'C' or 'M'
  local status_hls = {
    A = 'SnacksPickerGitStatusAdded',
    M = 'SnacksPickerGitStatusModified',
    D = 'SnacksPickerGitStatusDeleted',
    R = 'SnacksPickerGitStatusRenamed',
    C = 'SnacksPickerGitStatusCopied',
  }
  ret[#ret + 1] = { status .. ' ', status_hls[status] or 'SnacksPickerGitStatus', virtual = true }

  -- file name
  vim.list_extend(ret, Snacks.picker.format.filename(item, picker))

  return ret
end

--- Highlight all occurrences of search terms (split by spaces) in preview buffer.
--- @param buf number Buffer handle
--- @param ns number Namespace for highlights
--- @param search string Search query to highlight (may contain multiple words)
--- @return number|nil first_match_line Line number of first match (0-based)
local function highlight_search_matches(buf, ns, search)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if search == '' then
    return nil
  end

  -- Split search query by spaces to get individual search terms
  local search_terms = vim.iter(search:gmatch('%S+')):filter(function(term) return term ~= '' end):totable()

  if #search_terms == 0 then
    return nil
  end

  local line_count = vim.api.nvim_buf_line_count(buf)
  local first_match_line ---@type number?

  for lnum = 0, line_count - 1 do
    local line_text = vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ''

    -- Highlight each search term in the line
    vim.iter(search_terms):each(function(term)
      -- Use smartcase: case-insensitive if term is all lowercase
      local ignorecase = term == term:lower()
      local haystack = ignorecase and line_text:lower() or line_text
      local needle = ignorecase and term:lower() or term

      local col = 1
      while col <= #haystack do
        local from, to = haystack:find(needle, col, true)
        if not from then
          break
        end
        pcall(
          vim.api.nvim_buf_set_extmark,
          buf,
          ns,
          lnum,
          from - 1,
          { end_col = to, hl_group = 'IncSearch', priority = 4096 }
        )
        if not first_match_line then
          first_match_line = lnum
        end
        col = to + 1
      end
    end)
  end

  return first_match_line
end

--- Render diff preview with search highlighting.
--- @param ctx snacks.picker.preview.ctx Preview context
--- @param ns_search number Namespace for search highlights
local function render_diff_preview(ctx, ns_search)
  local preview_ns = vim.api.nvim_create_namespace('snacks.picker.preview')
  local diff_str = ctx.item.diff
  if not diff_str or diff_str == '' then
    ctx.preview:notify('No diff available', 'warn')
    return
  end

  -- Render the diff using snacks fancy diff renderer
  local buf = ctx.preview:scratch()
  ctx.preview.win:map()
  require('snacks.picker.util.diff').render(buf, preview_ns, diff_str, {
    annotations = ctx.item.annotations or ctx.picker.opts.annotations,
  })
  Snacks.util.wo(ctx.win, ctx.picker.opts.previewers.diff.wo or {})

  local current_filter = ctx.picker:filter()
  local search = vim.trim(current_filter.search or '')
  local pattern = vim.trim(current_filter.pattern or '')
  local query = search .. ' ' .. pattern
  local first_match_line = highlight_search_matches(buf, ns_search, query)

  -- Scroll to first match
  if first_match_line and vim.api.nvim_win_is_valid(ctx.win) then
    vim.api.nvim_win_set_cursor(ctx.win, { first_match_line + 1, 0 })
    vim.api.nvim_win_call(ctx.win, function() vim.cmd('norm! zz') end)
  end
end

---@param _ snacks.picker.Config
---@param ctx snacks.picker.finder.ctx
---@return snacks.picker.finder.async
local function finder_diff(_, ctx, picker_opts, include)
  local cwd = Snacks.git.get_root(ctx.filter.cwd) or ctx.filter.cwd
  ctx.picker:set_cwd(cwd)

  local base_args = build_diff_args(picker_opts.base)
  local run_staged = picker_opts.staged
  local run_both = (picker_opts.staged == nil and picker_opts.base == nil)

  ---@param cb async fun(item:snacks.picker.finder.Item)
  return function(cb)
    local all_blocks = {} ---@type { block: snacks.picker.diff.Block, staged: boolean }[]

    if run_staged or run_both then
      vim.list_extend(all_blocks, collect_diff_blocks(ctx, cwd, base_args, { '--cached' }, true))
    end
    if not run_staged or run_both then
      vim.list_extend(all_blocks, collect_diff_blocks(ctx, cwd, base_args, {}, false))
    end

    local by_file, file_order = group_blocks_by_file(all_blocks)

    for _, file in ipairs(file_order) do
      local data = by_file[file]

      -- Build combined diff string for preview (all hunks for this file)
      local diff_string, has_staged, first_block = build_file_diff(data.blocks)

      -- Build searchable text: join all changed content lines
      ---@type string[]
      local all_content = vim
        .iter(data.blocks)
        :map(function(entry) return extract_block_content(entry.block, include) end)
        :flatten()
        :totable()

      local joined_content = file .. '\n' .. table.concat(all_content, '\n')

      if
        ctx.filter:match({ file = file, text = joined_content })
        and text_matches_search(joined_content, ctx.filter.search or '')
      then
        cb({
          text = joined_content,
          file = file,
          cwd = cwd,
          pos = { data.first_line, 0 },
          diff = diff_string,
          block = first_block,
          staged = has_staged or nil,
        })
      end
    end
  end
end

--- Git diff content picker: search through added/deleted lines in git diff.
--- Shows one item per file, with all changed content searchable.
--- The preview shows the full diff with search matches highlighted.
--- @param picker_opts? { staged?: boolean, base?: string, base_branches?: string[], include?: 'changes'|'all'|'additions'|'deletions' }
function M.git_diff_content(picker_opts)
  picker_opts = picker_opts or {}
  local include = picker_opts.include or 'changes'

  -- Resolve base from base_branches if base is not explicitly set
  if not picker_opts.base and picker_opts.base_branches then
    local cwd = Snacks.git.get_root() or vim.uv.cwd()
    picker_opts.base = M.resolve_base_branch(picker_opts.base_branches, cwd)
    if not picker_opts.base then
      vim.notify('No matching base branch found', vim.log.levels.WARN)
      return
    end
  end

  local ns_search = vim.api.nvim_create_namespace('snacks.picker.git_diff_content.search')
  local title = picker_opts.base and ('Git Grep ' .. picker_opts.base) or 'Git Grep'

  Snacks.picker.pick({
    source = 'git_diff_content',
    title = title,
    live = true,
    supports_live = true,
    matcher = { sort_empty = true, fuzzy = false },
    finder = function(config, ctx) return finder_diff(config, ctx, picker_opts, include) end,
    format = format_diff_item,
    preview = function(ctx) render_diff_preview(ctx, ns_search) end,
  })
end

return M
