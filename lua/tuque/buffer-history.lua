local buffer_history = {}
local history_length = 5

--- @return boolean
local function include_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].buflisted
    and (vim.bo[buf].buftype == '' or vim.b[buf].buffer_history == true)
end

local function trim_and_filter_dead()
  buffer_history = vim.tbl_filter(include_buffer, buffer_history)

  while #buffer_history > history_length do
    table.remove(buffer_history, history_length + 1)
  end
end

--- @param buf number
local function add_to_history(buf)
  if not include_buffer(buf) then return end

  -- Remove the buffer if it's already in history
  for i, v in ipairs(buffer_history) do
    if v == buf then
      table.remove(buffer_history, i)
      break
    end
  end

  table.insert(buffer_history, 1, buf)
  trim_and_filter_dead()
end

vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('tuque.buffer-history', {}),
  callback = function(evt)
    vim.schedule(function() add_to_history(evt.buf) end)
  end,
})

--- @param n number
local function get_nth_previous_buffer(n)
  trim_and_filter_dead()

  -- Ignore visible buffers
  local excluded_bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    table.insert(excluded_bufs, vim.api.nvim_win_get_buf(win))
  end
  local buffer_history_filtered = vim.tbl_filter(
    function(buf) return not vim.tbl_contains(excluded_bufs, buf) end,
    buffer_history
  )

  return buffer_history_filtered[n] or buffer_history[n]
end

--- @class tuque.BufferHistory
return { get_nth_previous_buffer = get_nth_previous_buffer }
