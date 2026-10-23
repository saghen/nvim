-- each project runs in its own nvim server, which we can :detach from
-- the sockets are named after the project's path, and nvim-launch (nixfiles)
-- starts or attaches to the server for $HOME. other instances (e.g. `nvim` in a terminal)
-- belong to the folder they were started in
local servers_dir = (vim.env.XDG_RUNTIME_DIR or vim.fn.stdpath('run')) .. '/tuque'
local sessions_dir = vim.fn.stdpath('data') .. '/sessions'
local recency_path = vim.fn.stdpath('data') .. '/project-recency'

local M = {}

local function server_path(project_folder) return ('%s/%s.sock'):format(servers_dir, (project_folder:gsub('/', '%%'))) end

local function list_projects()
  local folders = {}
  local globs = { '~/code/*/*', '~/code/personal/keyboards/*' }
  for _, glob in ipairs(globs) do
    vim.list_extend(folders, vim.fn.glob(glob, nil, true))
  end
  return folders
end

local function server_project(sock) return (vim.fn.fnamemodify(sock, ':t:r'):gsub('%%', '/')) end

local function is_server_alive(sock)
  local ok, chan = pcall(vim.fn.sockconnect, 'pipe', sock, { rpc = true })
  if not ok or chan == 0 then return false end
  vim.fn.chanclose(chan)
  return true
end

local function list_open_projects()
  local socks = vim.tbl_filter(is_server_alive, vim.fn.glob(servers_dir .. '/*.sock', true, true))
  return vim.tbl_map(server_project, socks)
end

function M.is_project_server() return vim.startswith(vim.v.servername, servers_dir) end

-- instances opened on files (e.g. `nvim foo.txt`, `git commit`) or stdin have no project, so they
-- don't clobber its session
local current_project = M.is_project_server() and server_project(vim.v.servername)
  or (vim.fn.argc() == 0 and vim.fn.getcwd() or nil)

-- `:connect!` exits without checking for unsaved changes
local function has_unsaved_changes()
  for _, buf in ipairs(vim.fn.getbufinfo({ bufmodified = 1 })) do
    if vim.list_contains({ '', 'acwrite' }, vim.bo[buf.bufnr].buftype) then
      local name = buf.name == '' and '[No Name]' or vim.fn.fnamemodify(buf.name, ':~:.')
      vim.notify(('E162: No write since last change for buffer "%s"'):format(name), vim.log.levels.ERROR)
      return true
    end
  end
  return false
end

local function read_recent_projects()
  local ok, result = pcall(vim.fn.readfile, recency_path)
  return ok and result or {}
end

-- moves the project to the top of the list, keeping the 50 most recent
local function write_recent_projects(project_folder)
  local recency = vim.tbl_filter(function(entry) return entry ~= project_folder end, read_recent_projects())
  table.insert(recency, 1, project_folder)
  vim.fn.writefile(vim.list_slice(recency, 1, 50), recency_path)
end

--- @param project_folder string
--- @param stop_current? boolean Stop the current server if no other UIs are attached
local function open_project(project_folder, stop_current)
  local sock = server_path(project_folder)
  if sock == vim.v.servername then return end

  -- other instances would keep running headless and unreachable after the UI leaves
  if not M.is_project_server() then
    if has_unsaved_changes() then return end
    stop_current = true
  end
  write_recent_projects(project_folder)

  if not is_server_alive(sock) then
    os.remove(sock) -- remove dangling socket

    -- spawn fully detached, with no connection to this instance
    vim.system(
      { 'env', '-u', 'NVIM', 'nvim', '--headless', '--listen', sock },
      { cwd = project_folder, detach = true, stdout = false, stderr = false }
    )
    if not vim.wait(5000, function() return vim.uv.fs_stat(sock) ~= nil end, 10) then
      return vim.notify('Failed to start nvim server for ' .. project_folder, vim.log.levels.ERROR)
    end
  end
  vim.cmd((stop_current and 'connect! ' or 'connect ') .. vim.fn.fnameescape(sock))
end

-- the most recently used project with a running server, falling back to the home server
local function last_project()
  local current = server_project(vim.v.servername)
  for _, project_folder in ipairs(read_recent_projects()) do
    if project_folder ~= current and is_server_alive(server_path(project_folder)) then return project_folder end
  end
  if current ~= vim.env.HOME then return vim.env.HOME end
end

-- stops the current project's server and switches to the last project, only exiting
-- the window when quitting the home server with no other projects open
function M.quit_project(force)
  if not force and has_unsaved_changes() then return end

  local project_folder = last_project()
  if project_folder == nil then return vim.cmd(force and 'qa!' or 'qa') end
  open_project(project_folder, true)
end

function M.pick_project()
  local current = current_project
  local open_projects = list_open_projects()
  local recency_rank = {}
  for rank, project_folder in ipairs(read_recent_projects()) do
    recency_rank[project_folder] = rank
  end

  -- open projects first, then the current one, then the rest, each by recency
  local function group(project_folder)
    if project_folder == current then return 1 end
    return vim.list_contains(open_projects, project_folder) and 0 or 2
  end
  local projects = list_projects()
  table.sort(projects, function(a, b)
    if group(a) ~= group(b) then return group(a) < group(b) end
    local rank_a, rank_b = recency_rank[a] or math.huge, recency_rank[b] or math.huge
    if rank_a ~= rank_b then return rank_a < rank_b end
    return a < b
  end)

  local function search_text(project_folder) return vim.fn.fnamemodify(project_folder, ':t') .. ' ' .. project_folder end

  require('minibuffer').select({
    prompt = 'Projects: ',
    fetch_fn = function(_, cb) cb(projects) end,
    -- matchfuzzy keeps the order above for equal scores
    filter_fn = function(ctx)
      if ctx.input == '' then return ctx.items end
      return vim.fn.matchfuzzy(ctx.items, ctx.input, { text_cb = search_text })
    end,
    format_fn = function(project_folder)
      local icon, icon_hl = require('mini.icons').get('directory', project_folder)
      return {
        { text = ({ '•', '∘', ' ' })[group(project_folder) + 1] .. ' ' },
        { text = icon .. ' ', hl = icon_hl },
        { text = ('%-30s '):format(vim.fn.fnamemodify(project_folder, ':t')), hl = 'Normal' },
        { text = project_folder, hl = 'MinibufferPath' },
      }
    end,
    on_accept = function(selection) open_project(selection[1].item) end,
  })
end

-- the home folder is a scratchpad, so it has no session
local function session_path()
  if current_project == nil or current_project == vim.env.HOME then return end
  -- named the same as neovim-session-manager, so that its sessions keep loading
  return ('%s/%s'):format(sessions_dir, (current_project:gsub('/', '__')))
end

local function load_session()
  local path = session_path()
  if path == nil or not vim.uv.fs_stat(path) then return end

  -- project servers are headless, so a swap file prompt would hang them
  local swapfile = vim.o.swapfile
  vim.o.swapfile = false
  local ok, err = pcall(vim.cmd, 'silent source ' .. vim.fn.fnameescape(path))
  vim.o.swapfile = swapfile
  if not ok then return vim.notify('Failed to load session: ' .. err, vim.log.levels.ERROR) end
end

local function save_session()
  local path = session_path()
  if path == nil then return end

  -- windows of 'nofile' buffers and terminals are skipped, since they're missing
  -- from 'sessionoptions'
  vim.fn.mkdir(sessions_dir, 'p')
  vim.cmd('mksession! ' .. vim.fn.fnameescape(path))
end

vim.opt.sessionoptions = { 'buffers', 'curdir', 'folds', 'globals', 'tabpages', 'winsize' }

local group = vim.api.nvim_create_augroup('tuque.session', {})
vim.api.nvim_create_autocmd('StdinReadPre', { group = group, callback = function() current_project = nil end })
-- nested, so that the session's buffers run their BufRead/FileType autocmds
vim.api.nvim_create_autocmd('VimEnter', { group = group, nested = true, callback = load_session })
-- servers get killed without VimLeavePre (e.g. on shutdown), so save on write too
vim.api.nvim_create_autocmd({ 'BufWritePre', 'VimLeavePre' }, { group = group, callback = save_session })

return M
