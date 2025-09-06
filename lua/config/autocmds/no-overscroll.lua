vim.api.nvim_create_autocmd('WinScrolled', {
  callback = function(ev)
    local win = tonumber(ev.match)
    assert(win, 'winnr is not a number')

    local buf = vim.api.nvim_win_get_buf(win)
    local line_count = vim.api.nvim_buf_line_count(buf)

    local win_height = math.min(vim.api.nvim_win_get_height(win), line_count)

    -- top line number + window height should be <= line_count
    local last_visible_line = vim.fn.line('w0', win) + win_height - 1
    local out_of_buf_lines = last_visible_line - line_count

    if out_of_buf_lines > 0 then
      vim.api.nvim_win_call(win, function()
        vim.fn.winrestview({
          topline = math.max(1, line_count - win_height + 1),
        })
        -- https://github.com/neovim/neovim/issues/35633#issuecomment-3256274806
        vim.api.nvim_feedkeys(vim.keycode('<Ignore>'), 'ni', false)
      end)
    end
  end,
})
