--- @alias tuque.TerminalType 'normal' | 'agent'

--- @class tuque.Terminal
--- @field buf number
--- @field type tuque.TerminalType
local Terminal = {}

function Terminal.new(type)
  vim.cmd('terminal')
  vim.cmd('startinsert')

  local self = setmetatable({}, { __index = Terminal })
  self.buf = vim.api.nvim_get_current_buf()
  self.type = type or 'normal'
  if vim.bo[self.buf].buftype ~= 'terminal' then
    error("created a terminal buffer but didn't find it as the current buffer after creating it")
  end

  return self
end

function Terminal:is_valid() return vim.api.nvim_buf_is_valid(self.buf) end

--- @param win number?
--- @return boolean
function Terminal:is_focused(win) return vim.api.nvim_win_get_buf(win or 0) == self.buf end

--- @return boolean
function Terminal:is_visible() return #vim.fn.win_findbuf(self.buf) > 0 end

function Terminal:focus()
  local in_terminal_mode = vim.api.nvim_get_mode().mode == 't'
  if in_terminal_mode then vim.cmd.stopinsert() end
  vim.api.nvim_set_current_buf(self.buf)
  if in_terminal_mode then vim.schedule(vim.cmd.startinsert) end
end

return Terminal
