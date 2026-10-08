-- each project runs in its own nvim server, which outlives the UI attached to it. the sockets are named
-- after the project's path, and nvim-launch (nixfiles) starts or attaches to the server for $HOME
local servers_dir = vim.env.XDG_RUNTIME_DIR .. '/tuque'

local function server_path(project_folder) return ('%s/%s.sock'):format(servers_dir, (project_folder:gsub('/', '%%'))) end

local function list_projects()
  local top_level_folders = {
    '~/code/gamedev/*',
    '~/code/linux/*',
    '~/code/nvim/*',
    '~/code/personal/*',
    '~/code/personal/keyboards/*',
    '~/code/speechify/*',
    '~/code/superfishial/*',
    '~/notes',
  }
  local project_folders = {}
  for _, folder in ipairs(top_level_folders) do
    local child_folders = vim.fn.glob(folder, nil, true)
    vim.list_extend(project_folders, child_folders)
  end
  return project_folders
end

local function list_open_projects()
  return vim.tbl_map(
    function(sock) return (vim.fn.fnamemodify(sock, ':t:r'):gsub('%%', '/')) end,
    vim.fn.glob(servers_dir .. '/*.sock', true, true)
  )
end

local function open_project(project_folder)
  -- not running as a project server (i.e. plain `nvim`), so switch in place
  if not vim.startswith(vim.v.servername, servers_dir) then
    vim.cmd('cd ' .. project_folder)
    vim.cmd('SessionManager load_current_dir_session')
    return
  end

  local sock = server_path(project_folder)
  if sock == vim.v.servername then return end
  if not vim.uv.fs_stat(sock) then
    -- unset $NVIM so that flatten.nvim doesn't treat the server as a guest and exit.
    -- no stdout/stderr pipes, since the server would die writing to them after we exit
    vim.system(
      { 'env', '-u', 'NVIM', 'nvim', '--headless', '--listen', sock },
      { cwd = project_folder, detach = true, stdout = false, stderr = false }
    )
    -- connecting to a socket that never comes up hangs, so bail
    if not vim.wait(5000, function() return vim.uv.fs_stat(sock) ~= nil end, 10) then
      return vim.notify('Failed to start nvim server for ' .. project_folder, vim.log.levels.ERROR)
    end
  end
  vim.cmd.connect(vim.fn.fnameescape(sock))
end

local function read_recent_projects()
  local ok, result = pcall(vim.fn.readfile, vim.fn.stdpath('data') .. '/project-recency')
  if not ok then return {} end
  return result
end

local function write_recent_projects(project_folder)
  local recency = read_recent_projects()

  -- add/move to top of list
  recency = vim.tbl_filter(function(entry) return entry ~= project_folder end, recency)
  table.insert(recency, 1, project_folder)

  -- truncate to 50 entries
  recency = vim.list_slice(recency, 1, 50)

  -- write
  vim.fn.writefile(recency, vim.fn.stdpath('data') .. '/project-recency')
end

local function project_picker()
  local project_folders = list_projects()
  local open_projects = list_open_projects()
  local cwd = vim.fn.expand(vim.fn.getcwd())
  local recent_projects = read_recent_projects()

  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local entry_display = require('telescope.pickers.entry_display')

  local displayer = entry_display.create({
    separator = ' ',
    items = { {}, { width = 30 }, { remaining = true } },
  })
  local entry_maker = function(project_folder)
    local name = vim.fn.fnamemodify(project_folder, ':t')
    local is_open = vim.tbl_contains(open_projects, project_folder)
    local is_current = cwd == project_folder
    local recency_score = 0
    for idx, recent_project in ipairs(recent_projects) do
      if recent_project == project_folder then
        recency_score = -(50 - idx) / 50 / 100
        break
      end
      if idx >= 50 then break end
    end
    return {
      display = function(entry)
        return displayer({
          entry.is_current and '∘' or entry.is_open and '•' or ' ',
          entry.name,
          { entry.value, 'Comment' },
        })
      end,
      name = name,
      value = project_folder,
      is_open = is_open,
      is_current = is_current,
      recency_score = recency_score,
      ordinal = project_folder,
    }
  end

  local sorter = conf.generic_sorter({})
  local orig_scoring_function = sorter.scoring_function
  sorter.scoring_function = function(sorter, prompt, project_folder)
    local entry = entry_maker(project_folder)
    local recency_score = entry.recency_score / 100
    if #prompt == 0 then return recency_score + (entry.is_current and 0.5 or entry.is_open and 0 or 1) end

    local score = orig_scoring_function(sorter, prompt, entry.name .. ' ' .. entry.value)
    return math.max(-1, recency_score + (entry.is_open and score - 0.005 or score))
  end

  pickers
    .new({}, {
      prompt_title = 'Projects',
      finder = finders.new_table({
        results = project_folders,
        entry_maker = entry_maker,
      }),
      sorter = sorter,
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local project_folder = action_state.get_selected_entry().value
          write_recent_projects(project_folder)
          open_project(project_folder)
        end)
        return true
      end,
    })
    :find()
end

return {
  -- project and session management
  {
    'Shatur/neovim-session-manager',
    lazy = vim.fn.getcwd() == os.getenv('HOME'),
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    cmd = { 'SessionManager', 'SessionManagerLoadDir' },
    keys = {
      {
        '<leader>-',
        project_picker,
        desc = 'Projects',
      },
      { '<leader>fs', '<cmd>SessionManager load_session<cr>', desc = 'Sessions' },
      { '<leader>fS', '<cmd>SessionManager delete_session<cr>', desc = 'Delete session' },
    },
    init = function()
      -- todo: open blink tree if it was previously open
      local sessions_group = vim.api.nvim_create_augroup('TuqueSessions', {})
      -- open blink tree (disabled in dev environment)
      if os.getenv('NVIM_DEV') == nil then
        vim.api.nvim_create_autocmd({ 'User' }, {
          pattern = 'SessionLoadPost',
          group = sessions_group,
          command = 'BlinkTree open silent',
        })
      end

      -- The dashboard returns the full path of the project but the
      -- NeovimProjectLoad command expects the path to be the same as the one in the projects list
      -- so we need to replace the home directory with ~
      vim.api.nvim_create_user_command('SessionManagerLoadDir', function(args)
        local cwd = vim.fn.expand(args.args)
        vim.cmd('cd ' .. cwd)
        vim.cmd('SessionManager load_current_dir_session')
      end, { nargs = 1 })
      vim.opt.sessionoptions = { 'buffers', 'curdir', 'folds', 'globals', 'tabpages', 'winsize' }

      -- Auto save session
      vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
        callback = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            -- Don't save while there's any 'nofile' buffer open.
            if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'nofile' then return end
          end
          require('session_manager').save_current_session()
        end,
      })
    end,
    config = function()
      local config = require('session_manager.config')
      require('session_manager').setup({
        autoload_mode = { config.AutoloadMode.GitSession, config.AutoloadMode.CurrentDir },
        autosave_ignore_buftypes = { 'nowrite' },
        autosave_ignore_filetypes = { 'blink-tree' },
      })
    end,
  },
}
