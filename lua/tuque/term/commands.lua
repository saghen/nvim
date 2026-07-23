local M = {}

local actions = { 'cycle', 'focus', 'create' }
local types = { 'normal', 'agent' }

--- @param manager tuque.TerminalManager
function M.setup(manager)
  vim.api.nvim_create_user_command('TuqueTerm', function(args)
    if #args.fargs > 2 then error('Usage: TuqueTerm cycle|focus|create [type]') end

    local action = args.fargs[1]
    local type = args.fargs[2]

    if not vim.tbl_contains(actions, action) then error('Invalid TuqueTerm action: ' .. action) end
    if type and not vim.tbl_contains(types, type) then error('Invalid terminal type: ' .. type) end

    if action == 'cycle' then
      manager.cycle(type)
    elseif action == 'focus' then
      manager.focus_last(type)
    else
      manager.create(type)
    end
  end, {
    nargs = '+',
    desc = 'Manage Tuque terminals',
    complete = function(_, cmd_line)
      local args = vim.split(cmd_line, '%s+', { trimempty = true })
      local ends_with_space = cmd_line:sub(-1) == ' '

      if #args == 1 or (#args == 2 and not ends_with_space) then return actions end
      if #args == 2 or (#args == 3 and not ends_with_space) then return types end
      return {}
    end,
  })
end

return M
