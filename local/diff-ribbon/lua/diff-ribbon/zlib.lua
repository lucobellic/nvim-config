local ffi = require('ffi')

local M = {}

pcall(
  ffi.cdef,
  [[
  unsigned long compressBound(unsigned long source_length);
  int compress2(char *destination, unsigned long *destination_length, const char *source, unsigned long source_length, int level);
]]
)

--- Some systems only ship the versioned library, without the development link.
---@return ffi.namespace*?
local function load()
  for _, name in ipairs({ 'z', 'libz.so.1' }) do
    local loaded, library = pcall(ffi.load, name)
    if loaded then
      return library
    end
  end
  return nil
end

local library = load()

-- Fastest level: ribbon images are mostly transparent, so even light compression shrinks them a lot.
local LEVEL = 1

--- Compress with zlib, or return nil when zlib is missing or fails, so callers send the raw bytes.
---@param data string
---@return string?
function M.compress(data)
  if not library then
    return nil
  end
  local bound = library.compressBound(#data)
  local buffer = ffi.new('char[?]', bound)
  local length = ffi.new('unsigned long[1]', bound)
  if library.compress2(buffer, length, data, #data, LEVEL) ~= 0 then
    return nil
  end
  return ffi.string(buffer, length[0])
end

return M
