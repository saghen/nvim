local Terminal = require('tuque.term.term')

--- @class tuque.TerminalManager
local Manager = {
  --- @type tuque.Terminal[]
  terms = {},
  --- @type tuque.Terminal[]
  term_history = {},
}

local group = vim.api.nvim_create_augroup('tuque.term', {})

-- track terminal history
vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  callback = vim.schedule_wrap(function(ev)
    local term = Manager.get_term(ev.buf)
    if term == nil then return end
    Manager.term_history = vim.tbl_filter(function(other) return other ~= term end, Manager.get_term_history())
    table.insert(Manager.term_history, 1, term)
  end),
})

-- use signcolumn as padding
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinNew', 'WinClosed' }, {
  group = group,
  callback = vim.schedule_wrap(function()
    local signcolumn = vim.fn.winlayout()[1] == 'leaf' and 'no' or 'yes'
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if Manager.get_current_term(win) then
        vim.api.nvim_set_option_value('signcolumn', signcolumn, { scope = 'local', win = win })
      end
    end
  end),
})

-- ensure signcolumn uses cursorline highlight
vim.api.nvim_create_autocmd('TermOpen', {
  group = group,
  callback = function() vim.opt_local.cursorlineopt = 'line' end,
})

-- remove the default TermClose autocmd which closes the window on terminal exit,
-- keeping the one that shows "[Process exited]" for terminals we don't manage
local term_close_autocmds = vim.api.nvim_get_autocmds({ group = 'nvim.terminal', event = 'TermClose' })
for _, autocmd in ipairs(term_close_autocmds) do
  if autocmd.desc and autocmd.desc:match('^Automatically close') then pcall(vim.api.nvim_del_autocmd, autocmd.id) end
end

-- Replace terminal buffer with last buffer on exit
vim.api.nvim_create_autocmd('TermClose', {
  group = group,
  callback = function(args)
    local buf = args.buf
    -- only our terminals, so that the output of e.g. `:term cargo test` sticks around
    if not vim.api.nvim_buf_is_valid(buf) or Manager.get_term(buf) == nil then return end

    -- Swap the buffer out of its windows *before* deleting it, since deleting a buffer
    -- closes all windows displaying it
    local wins = vim.fn.win_findbuf(buf)
    if #wins > 0 then
      local alt

      -- prefer last term of the same type if it exists
      local term = Manager.get_term(buf)
      local other_term = term and Manager.get_last_hidden_term(term.type)
      if other_term then alt = other_term.buf end

      -- otherwise, last buffer
      if not alt then
        local buffer_history = require('tuque.buffer-history')
        alt = buffer_history.get_nth_previous_buffer(1, true) or buffer_history.get_nth_previous_buffer(1)
      end
      if not alt or alt == buf or not vim.api.nvim_buf_is_valid(alt) then alt = vim.api.nvim_create_buf(true, false) end

      for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_set_buf(win, alt) end
      end
    end

    vim.api.nvim_buf_delete(buf, { force = true })
  end,
})

--- @param type tuque.TerminalType?
--- @return tuque.Terminal[]
function Manager.get_terms(type)
  local terms = vim.tbl_filter(function(term) return term:is_valid() end, Manager.terms)
  Manager.terms = terms
  if not type then return terms end
  return vim.tbl_filter(function(term) return term.type == type end, terms)
end

function Manager.get_term_history()
  local term_history = vim.tbl_filter(function(term) return term:is_valid() end, Manager.term_history)
  Manager.term_history = term_history
  return term_history
end

--- @param buf number
--- @return tuque.Terminal?
function Manager.get_term(buf)
  return vim.iter(Manager.get_terms()):find(function(term) return term.buf == buf end)
end

--- @param win number?
--- @return tuque.Terminal?
function Manager.get_current_term(win) return Manager.get_term(vim.api.nvim_win_get_buf(win or 0)) end

--- Most recently focused terminal that isn't visible in any window
--- @param type tuque.TerminalType?
--- @return tuque.Terminal?
function Manager.get_last_hidden_term(type)
  local function is_hidden(term) return (not type or term.type == type) and not term:is_visible() end
  return vim.iter(Manager.get_term_history()):find(is_hidden)
end

--- @param type tuque.TerminalType?
--- @param win number?
--- @return number?, tuque.Terminal?
function Manager.get_current_term_idx(type, win)
  local terms = Manager.get_terms(type)
  for idx, term in ipairs(terms) do
    if term:is_focused(win) then return idx, term end
  end
end

--- @param type tuque.TerminalType
function Manager.cycle(type)
  local terms = Manager.get_terms(type)
  local current_term_idx = Manager.get_current_term_idx(type)

  -- No terminal focused: focus the last terminal, or create one
  -- TODO: create a new terminal if all the existing are visible
  if current_term_idx == nil then
    if #terms > 0 then return Manager.focus_last(type) end
    return Manager.create(type)
  end

  if #terms == 1 then return vim.notify('No other terminals exist') end
  terms[(current_term_idx % #terms) + 1]:focus()
end

--- @param type tuque.TerminalType?
function Manager.focus_last(type)
  -- Prefer the last term that isn't currently visible, otherwise the first term
  local term = Manager.get_last_hidden_term(type) or Manager.get_terms(type)[1]
  if term == nil then error('No terminals found') end
  term:focus()
end

--- @param type tuque.TerminalType?
--- @return tuque.Terminal
function Manager.create(type)
  local term = Terminal.new(type)
  table.insert(Manager.terms, term)
  return term
end

return Manager
