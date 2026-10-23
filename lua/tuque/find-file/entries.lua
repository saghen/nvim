--- @class tuque.find_file.Entry
--- @field name string
--- @field path string
--- @field is_directory boolean
--- @field is_hidden boolean
--- @field sort_key string
--- @field link_target string | nil

--- @class tuque.find_file.Match
--- @field entry tuque.find_file.Entry
--- @field positions integer[] 0-indexed character positions of the query in the name

local async = vim.async
local fs_scandir = async.wrap(2, vim.uv.fs_scandir)
local fs_stat = async.wrap(2, vim.uv.fs_stat)
local fs_readlink = async.wrap(2, vim.uv.fs_readlink)

local entries = {}

--- Directories first, dotfiles last, then alphabetical
--- @param a tuque.find_file.Entry
--- @param b tuque.find_file.Entry
local function compare(a, b)
  if a.is_directory ~= b.is_directory then return a.is_directory end
  if a.is_hidden ~= b.is_hidden then return b.is_hidden end
  return a.sort_key < b.sort_key
end

--- Follows links to find whether they point to a directory, also when the filesystem doesn't report the type
--- @async
--- @param path string
--- @param name string
--- @param type string | nil
--- @return tuque.find_file.Entry
local function read_entry(path, name, type)
  local entry = {
    name = name,
    path = path,
    is_directory = type == 'directory',
    is_hidden = name:sub(1, 1) == '.',
    sort_key = name:lower(),
  }
  if type == 'link' or type == nil then
    local _, stat = fs_stat(path)
    entry.is_directory = stat ~= nil and stat.type == 'directory'
  end
  if type == 'link' then
    local _, target = fs_readlink(path)
    if target ~= nil and target:find('\n', 1, true) == nil then entry.link_target = target end
  end
  return entry
end

--- Runs in a fast event context, so it must not call `vim.fn` or `vim.api`
--- @async
--- @param directory string absolute path
--- @return tuque.find_file.Entry[]
function entries.read(directory)
  local _, handle = fs_scandir(directory)
  if handle == nil then return {} end

  -- plain concatenation, since vim.fs.joinpath is ~10x slower in large directories
  local prefix = directory
  if prefix:sub(-1) ~= '/' then prefix = prefix .. '/' end

  local result = {}
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if name == nil then break end
    -- newlines are valid in names, but can't be written to a buffer line
    if name:find('\n', 1, true) == nil then table.insert(result, read_entry(prefix .. name, name, type)) end
  end

  table.sort(result, compare)
  return result
end

--- Fuzzy matches the names against the query, best match first. Words separated by spaces match in any order
--- @param items tuque.find_file.Entry[]
--- @param query string
--- @return tuque.find_file.Match[]
function entries.filter(items, query)
  local result = {}
  if vim.trim(query) == '' then
    for _, entry in ipairs(items) do
      table.insert(result, { entry = entry, positions = {} })
    end
    return result
  end

  -- match on the names alone, which avoids converting every entry to a vimscript dict. No `limit`, since it keeps
  -- the first matches in the list rather than the best ones
  local names = {}
  local entries_by_name = {}
  for _, entry in ipairs(items) do
    table.insert(names, entry.name)
    entries_by_name[entry.name] = entry
  end
  local matched = vim.fn.matchfuzzypos(names, query)
  for index, name in ipairs(matched[1]) do
    table.insert(result, { entry = entries_by_name[name], positions = matched[2][index] })
  end
  return result
end

return entries
