local map = require('tuque.utils').map

vim.pack.add({ 'https://github.com/stevearc/quicker.nvim' })

local quicker = require('quicker')

map('n', '<leader>q', function() quicker.toggle() end, { desc = 'Quickfix' })
map('n', '<leader>l', function() quicker.toggle({ loclist = true }) end, { desc = 'Loclist' })

quicker.setup({
  opts = { winhighlight = 'Normal:NormalFloat,EndOfBuffer:NormalFloat,SignColumn:NormalFloat,Delimiter:QuickFixBorder' },
  borders = { vert = '│', strong_cross = '┿', strong_end = '┥', soft_cross = '┼', soft_end = '┤' },
  follow = { enabled = true },
})

-- quicker doesnt resize on plain `:copen`
-- https://github.com/stevearc/quicker.nvim/issues/20
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('tuque.quickfix', {}),
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= 'quickfix' then return end
    local count = vim.fn.win_gettype() == 'loclist' and #vim.fn.getloclist(0) or #vim.fn.getqflist()
    vim.api.nvim_win_resize(0, -1, math.max(4, math.min(count, 16)))
  end,
})
