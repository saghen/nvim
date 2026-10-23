local format = {}

-- columns taken outside of the line: the leading space added in plugins/minibuffer.lua and a right margin
local reserved_width = 2

--- @param bytes integer
--- @return string
local function human_size(bytes)
  if bytes < 1024 then return bytes .. 'B' end
  local size = bytes / 1024
  for _, unit in ipairs({ 'K', 'M', 'G' }) do
    if size < 1024 then return string.format('%.1f%s', size, unit) end
    size = size / 1024
  end
  return string.format('%.1fT', size)
end

--- @param seconds integer
--- @return string
local function relative_time(seconds)
  local age = os.time() - seconds
  if age < 60 then return 'now' end
  if age < 60 * 60 then return math.floor(age / 60) .. 'm ago' end
  if age < 60 * 60 * 24 then return math.floor(age / 60 / 60) .. 'h ago' end
  if age < 60 * 60 * 24 * 30 then return math.floor(age / 60 / 60 / 24) .. 'd ago' end
  return os.date('%Y-%m-%d', seconds) --[[@as string]]
end

--- Splits the name into chunks, highlighting the matched characters
--- @param name string
--- @param positions integer[]
--- @param hl_group string
--- @return minibuffer.util.HighlightChunk[]
local function name_chunks(name, positions, hl_group)
  -- with multiple words, the positions are in the order of the words and may overlap
  local sorted_positions = vim.fn.uniq(vim.fn.sort(vim.deepcopy(positions), 'n'))

  local chunks = {}
  local byte_col = 0
  for _, char_index in ipairs(sorted_positions) do
    local start_col = vim.str_byteindex(name, 'utf-32', char_index)
    local end_col = vim.str_byteindex(name, 'utf-32', char_index + 1)
    if start_col > byte_col then table.insert(chunks, { text = name:sub(byte_col + 1, start_col), hl = hl_group }) end
    table.insert(chunks, { text = name:sub(start_col + 1, end_col), hl = 'TuqueFindFileMatch' })
    byte_col = end_col
  end
  if byte_col < #name then table.insert(chunks, { text = name:sub(byte_col + 1), hl = hl_group }) end
  return chunks
end

--- Size and modification time, like marginalia
--- @param entry tuque.find_file.Entry
--- @return string
local function annotation(entry)
  local stat = vim.uv.fs_stat(entry.path)
  if stat == nil then return '' end

  local size = ''
  if not entry.is_directory then size = human_size(stat.size) end
  return string.format('%6s  %10s', size, relative_time(stat.mtime.sec))
end

--- @param match tuque.find_file.Match
--- @return minibuffer.util.HighlightLine
function format.line(match)
  local entry = match.entry
  local category = 'file'
  local name_hl = 'Normal'
  if entry.is_directory then
    category = 'directory'
    name_hl = 'Directory'
  end
  local icon, icon_hl = require('mini.icons').get(category, entry.name)

  local chunks = { { text = icon .. '  ', hl = icon_hl } }
  vim.list_extend(chunks, name_chunks(entry.name, match.positions, name_hl))
  if entry.is_directory then table.insert(chunks, { text = '/', hl = name_hl }) end
  if entry.link_target ~= nil then
    table.insert(chunks, { text = ' → ' .. entry.link_target, hl = 'MinibufferPath' })
  end

  -- right aligned annotation, dropped when the name doesn't leave room for it
  local meta = annotation(entry)
  local used_width = 0
  for _, chunk in ipairs(chunks) do
    used_width = used_width + vim.fn.strdisplaywidth(chunk.text)
  end
  local padding = vim.o.columns - reserved_width - used_width - vim.fn.strdisplaywidth(meta)
  if padding >= 2 then table.insert(chunks, { text = string.rep(' ', padding) .. meta, hl = 'MinibufferPath' }) end

  return chunks
end

return format
