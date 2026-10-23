-- Emacs style find-file in the minibuffer: the prompt holds the path being completed, one directory at a time
local Cache = require('tuque.find-file.cache')
local entries = require('tuque.find-file.entries')
local format = require('tuque.find-file.format')
local path = require('tuque.find-file.path')

local find_file = {}

--- Oil's directory, the terminal's shell directory, the file's directory or the working directory
--- @return string
local function initial_directory()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype == 'oil' then
    local directory = require('oil').get_current_dir(bufnr)
    if directory ~= nil then return directory end
  end
  if vim.bo[bufnr].buftype == 'terminal' and vim.b[bufnr].terminal_job_pid ~= nil then
    local directory = vim.uv.fs_readlink('/proc/' .. vim.b[bufnr].terminal_job_pid .. '/cwd')
    if directory ~= nil then return directory end
  end
  -- the name may not be a path, e.g. "diffview://"
  local name = vim.api.nvim_buf_get_name(bufnr)
  local directory = vim.fs.dirname(name)
  if vim.bo[bufnr].buftype == '' and name ~= '' and vim.fn.isdirectory(directory) == 1 then return directory end
  return vim.fn.getcwd()
end

--- @param session minibuffer.core.SelectSession
--- @return string
local function get_input(session) return session:get_ctx().input end

--- The shortcuts only apply at the end of the input, otherwise the key behaves as usual
--- @return boolean
local function cursor_at_end() return vim.api.nvim_win_get_cursor(0)[2] >= #vim.api.nvim_get_current_line() end

--- Runs the key as if it wasn't mapped, before any keys typed after it
--- @param keys string
local function feed_unmapped(keys) vim.api.nvim_feedkeys(vim.keycode(keys), 'ni', false) end

--- The selected entry, once the results have caught up with the input. Otherwise keys typed quickly, or a directory
--- that's slow to read, would act on the results of the previous input
--- @param session minibuffer.core.SelectSession
--- @return tuque.find_file.Match | nil
local function get_selected(session)
  local caught_up = vim.wait(1000, function() return not session:get_ctx().loading end, 5)
  if not caught_up then return nil end
  return session:get_selected()
end

--- The selected entry, or the typed path when nothing matches
--- @param session minibuffer.core.SelectSession
--- @return string
local function target_path(session)
  local match = get_selected(session)
  if match ~= nil then return match.entry.path end
  return path.resolve(get_input(session))
end

--- Opens files with the command, and directories in oil via the same command
--- @param target string
--- @param command string
local function open_path(target, command) vim.cmd[command]({ args = { target }, magic = { file = false } }) end

--- @param session minibuffer.core.SelectSession
--- @param target string
--- @param command string
local function open(session, target, command)
  session:close(function() open_path(target, command) end)
end

--- Replaces the query with the selected entry, entering it when it's a directory
--- @param session minibuffer.core.SelectSession
--- @param match tuque.find_file.Match
local function complete(session, match)
  local directory = path.split(get_input(session))
  local completed = directory .. match.entry.name
  if match.entry.is_directory then completed = completed .. '/' end
  session:set_input(completed)
end

--- @param session minibuffer.core.SelectSession
--- @param keyset minibuffer.util.Keyset
local function set_keymaps(session, keyset)
  keyset('i', '<CR>', function()
    local match = get_selected(session)
    if match ~= nil and match.entry.is_directory then return complete(session, match) end
    open(session, target_path(session), 'edit')
  end)
  -- opens exactly what was typed, creating the directory when it ends in a slash and doesn't exist
  keyset('i', '<M-CR>', function()
    local input = get_input(session)
    local target = path.resolve(input)
    if input:sub(-1) == '/' and vim.fn.isdirectory(target) == 0 then
      local ok, err = pcall(vim.fn.mkdir, target, 'p')
      if not ok then return vim.notify('[find-file] ' .. err, vim.log.levels.ERROR) end
    end
    open(session, target, 'edit')
  end)

  keyset('i', '<C-s>', function() open(session, target_path(session), 'split') end)
  keyset('i', '<C-v>', function() open(session, target_path(session), 'vsplit') end)
  keyset('i', '<C-t>', function() open(session, target_path(session), 'tabedit') end)

  -- by a page, stopping at the ends instead of wrapping around like <C-n> and <C-p>
  local function move_to(index)
    local ctx = session:get_ctx()
    if #ctx.items == 0 then return end
    session:move(math.max(1, math.min(#ctx.items, index)) - ctx.current_index)
  end
  keyset('i', '<PageDown>', function() move_to(session:get_ctx().current_index + session.max_height) end)
  keyset('i', '<PageUp>', function() move_to(session:get_ctx().current_index - session.max_height) end)
  keyset('i', '<M-lt>', function() move_to(1) end)
  keyset('i', '<M->>', function() move_to(math.huge) end)

  keyset('i', '<Tab>', function()
    local match = get_selected(session)
    if match ~= nil then complete(session, match) end
  end)

  -- backspace after a slash goes up a directory, but only deletes the last one of repeated slashes
  keyset('i', '<BS>', function()
    local input = get_input(session)
    local after_directory = input:sub(-1) == '/' and input:sub(-2) ~= '//' and input ~= '/'
    if not cursor_at_end() or not after_directory then return feed_unmapped('<BS>') end
    session:set_input(path.parent(input))
  end)

  -- deletes the query, then whole directories
  keyset('i', '<C-w>', function()
    local input = get_input(session)
    local directory, query = path.split(input)
    if not cursor_at_end() or input == '' or input == '/' then return feed_unmapped('<C-S-w>') end
    if query ~= '' then return session:set_input(directory) end
    session:set_input(path.parent(directory))
  end)

  keyset('i', '/', function()
    local tidied = path.tidy_slash(get_input(session))
    if not cursor_at_end() or tidied == nil then return feed_unmapped('/') end
    session:set_input(tidied)
  end)
end

--- Delivers the listing to the session, reporting failures which would otherwise be dropped silently
--- @param callback fun(items: tuque.find_file.Entry[] | nil, err: any)
--- @param ok boolean
--- @param result any
local function deliver(callback, ok, result)
  if ok then return callback(result) end
  vim.notify('[find-file] ' .. tostring(result), vim.log.levels.ERROR)
  callback(nil, result)
end

function find_file.open()
  local cache = Cache.new()
  local is_open = false

  require('minibuffer').select({
    prompt = 'Find file: ',
    initial_text = path.display_directory(initial_directory()),
    resumable = true,
    max_height = 15,
    dynamic_height = false,
    fetch_fn = function(input, callback)
      local task = vim.async.run(cache.get, cache, path.resolve(path.split(input)))
      -- before the session opens, wait for the read so that the window opens at its full height
      if not is_open then return deliver(callback, task:pwait()) end
      task:on_complete(function(err, items)
        vim.schedule(function()
          if err ~= nil then return deliver(callback, false, err) end
          deliver(callback, true, items)
        end)
      end)
    end,
    filter_fn = function(ctx)
      local _, query = path.split(ctx.input)
      return entries.filter(ctx.items, query)
    end,
    format_fn = format.line,
    on_start = function(session, keyset)
      is_open = true
      set_keymaps(session, keyset)
    end,
    on_close = function() is_open = false end,
    -- <C-y> accepts the selection as is, without entering directories
    on_accept = function(selection) open_path(selection[1].item.entry.path, 'edit') end,
  })
end

return find_file
