local protected_filetypes = { 'toggleterm' }

local function get_win_to_buf_map()
  local win_to_buf_map = {}
  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) then win_to_buf_map[win] = buf end
  end
  return win_to_buf_map
end

local function get_buf_win(buf)
  for win, buf2 in pairs(get_win_to_buf_map()) do
    if buf == buf2 then return win end
  end
end

--- @type table<number, number>
local win_to_buf_map = {}
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function(event)
    local curr_win = get_buf_win(event.buf)
    local prev_buf = win_to_buf_map[curr_win]

    if
      prev_buf == nil
      or not vim.api.nvim_buf_is_valid(prev_buf)
      or not vim.tbl_contains(protected_filetypes, vim.bo[prev_buf].filetype)
    then
      win_to_buf_map = get_win_to_buf_map()
      return
    end

    -- pick a suitable window to display the buffer in
    local suitable_win = nil
    for win, buf in pairs(win_to_buf_map) do
      if not vim.tbl_contains(protected_filetypes, vim.bo[buf].filetype) and vim.bo[buf].buflisted then
        suitable_win = win
        break
      end
    end

    -- create a new window, if there is no suitable window
    if suitable_win == nil then
      vim.api.nvim_command('vnew')
      suitable_win = vim.api.nvim_get_current_win()
    end

    -- set the buffer to the new window
    vim.api.nvim_win_set_buf(suitable_win, event.buf)

    -- restore previous buffer in current window
    vim.api.nvim_win_set_buf(curr_win, prev_buf)

    -- focus the new window
    vim.api.nvim_set_current_win(suitable_win)

    win_to_buf_map = get_win_to_buf_map()
  end,
})
