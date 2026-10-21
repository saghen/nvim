local M = {}

--- @type number[] terminal buffers in creation order
local terms = {}
--- @type number[] terminal buffers, most recently focused first
local history = {}

local group = vim.api.nvim_create_augroup('tuque.term', {})

-- track terminal history
vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  callback = vim.schedule_wrap(function(ev)
    if M.index(ev.buf) == nil then return end
    history = vim.tbl_filter(function(buf) return buf ~= ev.buf end, history)
    table.insert(history, 1, ev.buf)
  end),
})

-- use signcolumn as padding, with the cursorline highlight
vim.api.nvim_create_autocmd('TermOpen', {
  group = group,
  callback = function()
    vim.opt_local.signcolumn = 'yes'
    vim.opt_local.cursorlineopt = 'line'
  end,
})

-- remove the default TermClose autocmd which closes the window on terminal exit,
-- keeping the one that shows "[Process exited]" for terminals we don't manage
local term_close_autocmds = vim.api.nvim_get_autocmds({ group = 'nvim.terminal', event = 'TermClose' })
for _, autocmd in ipairs(term_close_autocmds) do
  if autocmd.desc and autocmd.desc:match('^Automatically close') then pcall(vim.api.nvim_del_autocmd, autocmd.id) end
end

--- Most recently focused terminal that isn't visible in any window
--- @return number?
local function last_hidden()
  return vim.iter(history):find(function(buf) return M.index(buf) ~= nil and #vim.fn.win_findbuf(buf) == 0 end)
end

--- @param buf number
local function focus(buf)
  local in_terminal_mode = vim.api.nvim_get_mode().mode == 't'
  if in_terminal_mode then vim.cmd.stopinsert() end
  vim.api.nvim_set_current_buf(buf)
  if in_terminal_mode then vim.schedule(vim.cmd.startinsert) end
end

-- Replace terminal buffer with last buffer on exit
vim.api.nvim_create_autocmd('TermClose', {
  group = group,
  callback = function(args)
    local buf = args.buf
    -- only our terminals, so that the output of e.g. `:term cargo test` sticks around
    if not vim.api.nvim_buf_is_valid(buf) or M.index(buf) == nil then return end

    -- Swap the buffer out of its windows *before* deleting it, since deleting a buffer
    -- closes all windows displaying it
    local wins = vim.fn.win_findbuf(buf)
    if #wins > 0 then
      -- prefer the last terminal, otherwise the last buffer
      local alt = last_hidden() or require('tuque.buffer-history').get_nth_previous_buffer(1)
      if not alt or alt == buf or not vim.api.nvim_buf_is_valid(alt) then alt = vim.api.nvim_create_buf(true, false) end

      for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_set_buf(win, alt) end
      end
    end

    vim.api.nvim_buf_delete(buf, { force = true })
  end,
})

--- @return number[]
function M.list()
  terms = vim.tbl_filter(vim.api.nvim_buf_is_valid, terms)
  return terms
end

--- @param buf number
--- @return number? index of the terminal in `M.list()`
function M.index(buf)
  for idx, term in ipairs(M.list()) do
    if term == buf then return idx end
  end
end

function M.cycle()
  local terms = M.list()
  local idx = M.index(vim.api.nvim_get_current_buf())

  -- No terminal focused: focus the last hidden terminal, or create one
  -- TODO: create a new terminal if all the existing are visible
  if idx == nil then
    local buf = last_hidden() or terms[1]
    if buf then return focus(buf) end
    return M.create()
  end

  if #terms == 1 then return vim.notify('No other terminals exist') end
  focus(terms[(idx % #terms) + 1])
end

function M.create()
  vim.cmd('terminal')
  vim.cmd('startinsert')
  table.insert(terms, vim.api.nvim_get_current_buf())
end

return M
