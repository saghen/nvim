local Terminal = require('tuque.term.term')

--- @class tuque.TerminalManager
local Manager = {
  --- @type tuque.Terminal[]
  terms = {},
  --- @type tuque.Terminal[]
  term_history = {},
}

-- Keep track of terminal history
vim.api.nvim_create_autocmd('BufEnter', {
  callback = vim.schedule_wrap(function(ev)
    for _, term in ipairs(Manager.get_terms()) do
      if term.buf == ev.buf then
        local term_history = Manager.get_term_history()

        -- Remove from history if it's already there
        for i, v in ipairs(term_history) do
          if v == term then
            table.remove(term_history, i)
            break
          end
        end

        table.insert(term_history, 1, term)
        return
      end
    end
  end),
})

-- Update left side padding when a buffer enters a window
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function()
    for _, term in ipairs(Manager.get_terms()) do
      term:update_padding()
    end
  end,
})

-- Run on BufLeave as well since ModeChanged doesn't fire when switching from terminal buffer
-- to another buffer, even though the mode changes
vim.api.nvim_create_autocmd('ModeChanged', {
  callback = function()
    for _, term in ipairs(Manager.get_terms()) do
      term:update_cursorline_highlight()
    end
  end,
})

-- Remove default TermClose autocmds which close the window
local term_close_autocmds = vim.api.nvim_get_autocmds({
  group = 'nvim.terminal',
  event = 'TermClose',
})
for _, autocmd in ipairs(term_close_autocmds) do
  pcall(vim.api.nvim_del_autocmd, autocmd.id)
end

-- Replace terminal buffer with last buffer on exit
vim.api.nvim_create_autocmd('TermClose', {
  callback = function(args)
    local buffer_history = require('tuque.buffer-history')
    local buf = args.buf
    local win = vim.fn.bufwinid(buf)
    if win == -1 or not vim.api.nvim_win_is_valid(win) then return end

    -- Find the alternate buffer for this window
    local alt = buffer_history.get_nth_previous_buffer(1, true) or buffer_history.get_nth_previous_buffer(1)
    if not alt or not vim.api.nvim_buf_is_valid(alt) then alt = vim.api.nvim_create_buf(true, false) end
    vim.api.nvim_win_set_buf(win, alt)

    -- Delete terminal buffer
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
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

--- @param win number?
--- @return tuque.Terminal?
function Manager.get_current_term(win)
  local terms = Manager.get_terms()
  for _, term in ipairs(terms) do
    if term:is_focused(win) then return term end
  end
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

  -- No terminal focused
  if current_term_idx == nil then
    -- Focus the last terminal
    -- TODO: create a new terminal if all the existing are visible
    if #terms > 0 then
      Manager.focus_last(type)
    -- Create a new terminal and focus it
    else
      Manager.create(type)
    end
  -- Terminal focused
  else
    if #terms == 1 then
      -- No other terminals exist
      vim.notify('No other terminals exist')
    else
      -- Focus the next terminal
      local next_term_idx = (current_term_idx % #terms) + 1
      return terms[next_term_idx]:focus()
    end
  end
end

--- @param type tuque.TerminalType?
function Manager.focus_last(type)
  -- Focus the last term that isn't currently visible
  for _, term in ipairs(Manager.get_term_history()) do
    if (not type or term.type == type) and not term:is_visible() then return term:focus() end
  end

  -- Focus the first term instead
  local terms = Manager.get_terms(type)
  if #terms > 0 then return terms[1]:focus() end

  error('No terminals found')
end

--- @param type tuque.TerminalType?
--- @return tuque.Terminal
function Manager.create(type)
  local term = Terminal.new(type)
  table.insert(Manager.terms, term)
  return term
end

return Manager
