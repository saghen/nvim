local async = vim.async
local entries = require('tuque.find-file.entries')

local fs_stat = async.wrap(2, vim.uv.fs_stat)

--- @class tuque.find_file.Listing
--- @field mtime { sec: integer, nsec: integer } of the directory when the read started
--- @field task vim.async.Task<tuque.find_file.Entry[]>

--- Directory listings, read again when the directory's mtime changes (i.e. entries were added, removed or renamed)
--- @class tuque.find_file.Cache
--- @field listings table<string, tuque.find_file.Listing>
local Cache = {}
Cache.__index = Cache

--- @return tuque.find_file.Cache
function Cache.new() return setmetatable({ listings = {} }, Cache) end

--- @async
--- @param directory string absolute path
--- @return tuque.find_file.Entry[]
function Cache:get(directory)
  local _, stat = fs_stat(directory)
  if stat == nil or stat.type ~= 'directory' then
    self.listings[directory] = nil
    return {}
  end

  local listing = self.listings[directory]
  if listing == nil or listing.mtime.sec ~= stat.mtime.sec or listing.mtime.nsec ~= stat.mtime.nsec then
    -- detached so that the read is shared by every fetch of the directory, instead of belonging to the first one
    listing = { mtime = stat.mtime, task = async.run(entries.read, directory):detach() }
    self.listings[directory] = listing
  end
  return async.await(listing.task)
end

return Cache
