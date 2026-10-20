local map = require('tuque.utils').map

map('i', '<C-backspace>', '<C-w>', { desc = 'Delete word' })

map({ 'n', 'x', 'o' }, "'", '`') -- To make room for ` as terminal key

map('n', 'C', 'ciw', { desc = 'Change inside word' })
map('n', 'Q', '<cmd>q<cr>', { desc = 'Quit' })

-- better up/down - allows moving to wrapped lines
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- better ^/$ via gh/gl/gs
map({ 'n', 'x', 'o' }, 'gl', '$')
map({ 'n', 'x', 'o' }, 'gh', '0')
map({ 'n', 'x', 'o' }, 'gs', '^')

-- move to window with alt + hjkl/arrows, in any mode
for dir, keys in pairs({
  left = { 'h', 'Left' },
  lower = { 'j', 'Down' },
  upper = { 'k', 'Up' },
  right = { 'l', 'Right' },
}) do
  for _, key in ipairs(keys) do
    map(
      { 'n', 'x', 'i', 't' },
      '<M-' .. key .. '>',
      '<C-\\><C-n><cmd>wincmd ' .. keys[1] .. '<cr>',
      { desc = 'Go to ' .. dir .. ' window' }
    )
  end
end

local function switch_to_nth_previous_buffer(n)
  return function()
    local prev_buf = require('tuque.buffer-history').get_nth_previous_buffer(n)
    if prev_buf ~= nil then
      vim.api.nvim_win_set_buf(0, prev_buf)
    else
      vim.notify('No previous buffer found')
    end
  end
end
map('n', '<leader>bb', switch_to_nth_previous_buffer(1), { desc = 'Other buffer' })
map('n', '<backspace>', switch_to_nth_previous_buffer(1), { desc = 'Other buffer' })
map('n', '<leader><backspace>', switch_to_nth_previous_buffer(2), { desc = 'Second previous buffer' })

-- Clear search highlight with <esc>
map({ 'i', 'n', 's' }, '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and clear hlsearch' })

-- Terminal
map('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
map('t', '<C-]>', '<Esc>', { desc = 'Pass <Esc> to terminal' })
map({ 'n', 'x' }, '`', function() require('tuque.term').cycle('normal') end, { desc = 'Cycle terminal' })
map({ 'n', 'x' }, '=', function() require('tuque.term').cycle('agent') end, { desc = 'Cycle agent terminal' })
-- acts on the same type as the current terminal, does nothing outside of terminals
local function term_action(action)
  return function()
    local term = require('tuque.term')
    local active_term = term.get_current_term()
    if active_term ~= nil then term[action](active_term.type) end
  end
end
map({ 'n', 'x', 't' }, '<M-g>', term_action('cycle'), { desc = 'Next terminal' })
map({ 'n', 'x', 't' }, '<M-n>', term_action('create'), { desc = 'Create terminal' })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next search result' })
map({ 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev search result' })
map({ 'x', 'o' }, 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev search result' })

-- projects and quit
-- project switching only works in project servers (i.e. nvim-launch), see tuque.session
local session = require('tuque.session')
if session.is_project_server() then
  map('n', '<leader>-', session.pick_project, { desc = 'Projects' })
  map('n', '<C-q>', function() session.quit_project(false) end, { desc = 'Quit project' })
else
  map('n', '<C-q>', '<cmd>qa<cr>', { desc = 'Quit all' })
end

-- ctrl based commands
map({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })

-- better indenting
map('x', '<', '<gv')
map('x', '>', '>gv')

-- options
map('n', '<leader>uw', '<cmd>set wrap!<cr>', { desc = 'Toggle line wrapping' })
map(
  'n',
  '<leader>uc',
  function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0 end,
  { desc = 'Toggle conceal' }
)

-- diagnostic
local diagnostic_goto = function(count, severity)
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() vim.diagnostic.jump({ count = count * vim.v.count1, severity = severity }) end
end
map('n', 'ge', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', ']e', diagnostic_goto(1, 'ERROR'), { desc = 'Next Error' })
map('n', '[e', diagnostic_goto(-1, 'ERROR'), { desc = 'Prev Error' })
map('n', ']w', diagnostic_goto(1, 'WARN'), { desc = 'Next Warning' })
map('n', '[w', diagnostic_goto(-1, 'WARN'), { desc = 'Prev Warning' })

-- windows
map('n', '<leader>w', '<C-w>', { remap = true, desc = 'Windows' })

-- clipboard
map('x', '<leader>p', '"+p', { desc = 'Paste from clipboard' })
map('n', '<leader>p', '"+p', { desc = 'Paste from clipboard' })
map('x', '<leader>P', '"+P', { desc = 'Paste from clipboard' })
map('n', '<leader>P', '"+P', { desc = 'Paste from clipboard' })
map('x', '<leader>y', '"+y', { desc = 'Yank to clipboard' })

-- copy
local function copy(text)
  vim.fn.setreg('+', text)
  vim.notify('Copied ' .. text)
end
map('n', '<leader>cp', function() copy(vim.fn.expand('%:.')) end, { desc = 'Copy relative path' })
map('n', '<leader>cP', function() copy(vim.fn.expand('%:p')) end, { desc = 'Copy absolute path' })
map(
  'n',
  '<leader>cl',
  function() copy(vim.fn.expand('%:.') .. ':' .. vim.fn.line('.')) end,
  { desc = 'Copy path:line' }
)
map('x', '<leader>cu', function()
  vim.cmd.normal({ '"zy', bang = true })
  local text = require('plenary.strings').dedent(vim.fn.getreg('z'))
  local response = require('plenary.curl').post('https://paste.super.fish/', { body = text })
  if not response.body then return vim.notify('Failed to upload to pastebin', vim.log.levels.ERROR) end
  copy('https://paste.super.fish' .. response.body .. '.' .. vim.fn.expand('%:e'))
end, { desc = 'Upload selection to pastebin' })
