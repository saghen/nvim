local map = require('tuque.utils').map

vim.pack.add({ 'https://github.com/simifalaye/minibuffer.nvim' })

vim.ui.select = require('minibuffer.builtin.ui_select')
vim.ui.input = require('minibuffer.builtin.ui_input')

local history = require('minibuffer.builtin.history')
local list = require('minibuffer.builtin.list')

map('n', ',', require('minibuffer.builtin.live-grep'), { desc = 'Live grep' })
map('n', '<leader>r', function() require('minibuffer').resume(true) end, { desc = 'Resume last search' })
map('n', "<leader>'", require('minibuffer.builtin.marks'), { desc = 'Marks' })
map('n', '<leader>:', function() history({ type = 'cmd' }) end, { desc = 'Command history' })
map('n', '<leader>?', function() history({ type = 'search' }) end, { desc = 'Search history' })
map('n', '<leader>.', require('minibuffer.builtin.buffers'), { desc = 'Buffers' })
map('n', '<tab>', require('minibuffer.builtin.files'), { desc = 'Files' })

map('n', '<leader>f/', require('minibuffer.builtin.live-grep'), { desc = 'Live grep' })
map('n', '<leader>fb', require('minibuffer.builtin.buffers'), { desc = 'Buffers' })
map('n', '<leader>fd', require('minibuffer.builtin.diagnostics'), { desc = 'Diagnostics' })
map('n', '<leader>ff', require('minibuffer.builtin.files'), { desc = 'Files' })
map('n', '<leader>fg', require('minibuffer.builtin.git-files'), { desc = 'Git files' })
map('n', '<leader>fl', function() list({ type = 'loclist' }) end, { desc = 'In loclist' })
map('n', '<leader>fm', require('minibuffer.builtin.marks'), { desc = 'Marks' })
map('n', '<leader>fo', require('minibuffer.builtin.oldfiles'), { desc = 'Old files' })
map('n', '<leader>fr', function() require('minibuffer').resume(true) end, { desc = 'Resume last search' })
map('n', '<leader>fq', function() list({ type = 'quickfix' }) end, { desc = 'In quickfix' })

-- the list's left border is padding that the selection highlight can't cover, so drop the side
-- borders (keeping the bottom one for the footer) and pad the lines instead
local SelectSession = require('minibuffer.sessions.select')
local pre_start = SelectSession.pre_start
function SelectSession:pre_start()
  pre_start(self)
  if self._display.win then
    vim.api.nvim_win_set_config(self._display.win, { border = { '', '', '', '', '', ' ', '', '' } })
  end
end

-- file icons for builtin pickers
local file_pickers = { 'files', 'git-files', 'oldfiles', 'buffers', 'live-grep', 'diagnostics', 'list', 'marks' }
local minibuffer = require('minibuffer')
local select = minibuffer.select
minibuffer.select = function(opts, force)
  local builtin = debug.getinfo(2, 'S').source:match('/builtin/([%w-]+)%.lua$')
  local with_icon = vim.list_contains(file_pickers, builtin)
  local format_fn = opts.format_fn
  opts.format_fn = function(item)
    local chunks = format_fn(item)
    if with_icon then
      local icon, hl = require('mini.icons').get('file', type(item) == 'string' and item or item.path or item.file)
      table.insert(chunks, 1, { text = icon .. '  ', hl = hl })
    end
    table.insert(chunks, 1, { text = ' ' })
    return chunks
  end
  return select(opts, force)
end
