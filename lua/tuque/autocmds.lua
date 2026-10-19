local group = vim.api.nvim_create_augroup('tuque.autocmds', {})

-- stop snippet session on insert leave
vim.api.nvim_create_autocmd('InsertLeave', { group = group, callback = vim.snippet.stop })

-- sets current line's color based on the current mode
local mode_hl_groups = {
  [''] = 'ModeVisual',
  v = 'ModeVisual',
  V = 'ModeVisual',
  ['\22'] = 'ModeVisual',
  n = 'ModeNormal',
  no = 'ModeNormal',
  i = 'ModeInsert',
  c = 'ModeCommand',
  s = 'ModeSelect',
  S = 'ModeSelect',
  R = 'ModeReplace',
  t = 'ModeTerminal',
  nt = 'ModeTerminal',
}
vim.api.nvim_create_autocmd({ 'BufEnter', 'ModeChanged' }, {
  group = group,
  callback = function()
    local mode = vim.api.nvim_get_mode().mode
    local mode_hl_group = mode_hl_groups[mode] or 'ModeNormal'
    local hl = vim.api.nvim_get_hl(0, { name = mode_hl_group, link = false })
    hl = vim.tbl_extend('force', { bold = true }, hl)
    vim.api.nvim_set_hl(0, 'CursorLineNr', hl)
  end,
})

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  callback = function() vim.hl.hl_op() end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = group,
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].tuque_last_loc then return end
    vim.b[buf].tuque_last_loc = true

    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- open help in the current window instead of a split
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = group,
  callback = function(ev)
    -- a fresh :help split has the previous (non-help) buffer as its alternate
    if vim.bo[ev.buf].buftype ~= 'help' or vim.bo[vim.fn.bufnr('#')].buftype == 'help' then return end
    local help_win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd('p')
    if vim.api.nvim_get_current_win() == help_win then return end
    vim.api.nvim_win_set_buf(0, ev.buf)
    vim.api.nvim_win_close(help_win, false)
  end,
})
