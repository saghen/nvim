local map = require('tuque.utils').map

-- never use the cmdline window, so remap q: to :q
-- which is what i usually meant
map('n', 'q:', ':q<cr>', { desc = 'Quit' })

map('i', '<C-backspace>', '<C-w>', { desc = 'Delete word' })

map('n', '-', '``', { desc = 'Jump to last edit location' })
map('n', "'", '`') -- To make room for ` as terminal key

map('n', 'C', 'ciw', { desc = 'Change inside word' })
map('n', 'Q', '<cmd>q<cr>', { desc = 'Quit' })

map('n', '<C-a>', 'ggVG', { desc = 'Select all' })

-- better up/down - allows moving to wrapped lines
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- better ^/$ via gh/gl/gs
map({ 'v', 'n' }, 'gl', '$', { noremap = true, silent = true })
map({ 'v', 'n' }, 'gh', '0', { noremap = true, silent = true })
map({ 'v', 'n' }, 'gs', '^', { noremap = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map({ 'n' }, '<C-h>', '<cmd>wincmd h<cr>', { desc = 'Go to left window' })
map({ 'n' }, '<C-j>', '<cmd>wincmd j<cr>', { desc = 'Go to lower window' })
map({ 'n' }, '<C-k>', '<cmd>wincmd k<cr>', { desc = 'Go to upper window' })
map({ 'n' }, '<C-l>', '<cmd>wincmd l<cr>', { desc = 'Go to right window' })

map('t', '<C-h>', '<C-\\><C-n><cmd>wincmd h<cr>', { noremap = true })
map('t', '<C-j>', '<C-\\><C-n><cmd>wincmd j<cr>', { noremap = true })
map('t', '<C-k>', '<C-\\><C-n><cmd>wincmd k<cr>', { noremap = true })

map('n', '<S-Left>', '<cmd>wincmd h<cr>', { desc = 'Go to left window', remap = true })
map('n', '<S-Down>', '<cmd>wincmd j<cr>', { desc = 'Go to lower window', remap = true })
map('n', '<S-Up>', '<cmd>wincmd k<cr>', { desc = 'Go to upper window', remap = true })
map('n', '<S-Right>', '<cmd>wincmd l<cr>', { desc = 'Go to right window', remap = true })

map('t', '<S-Left>', '<C-\\><C-n><cmd>wincmd h<cr>', { noremap = true })
map('t', '<S-Down>', '<C-\\><C-n><cmd>wincmd j<cr>', { noremap = true })
map('t', '<S-Up>', '<C-\\><C-n><cmd>wincmd k<cr>', { noremap = true })
map('t', '<S-Right>', '<C-\\><C-n><cmd>wincmd l<cr>', { noremap = true })

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
map('n', '<leader><backspace>', switch_to_nth_previous_buffer(2), { desc = 'Other buffer' })

-- jump to next/prev file
map('n', '[f', function()
  local current_file = vim.fn.expand('%:p')

  -- get all files in the directory, sorted
  local files = vim.fn.glob(vim.fn.expand('%:p:h') .. '/*', false, true)
  files = vim.tbl_filter(function(file) return vim.fn.isdirectory(file) == 0 end, files)
  table.sort(files)

  local index = vim.fn.index(files, current_file) + 1
  if index <= 1 then return end
  vim.cmd('e ' .. files[index - 1])
end, { desc = 'Prev file' })
map('n', ']f', function()
  local current_file = vim.fn.expand('%:p')

  -- get all files in the directory, sorted
  local files = vim.fn.glob(vim.fn.expand('%:p:h') .. '/*', false, true)
  files = vim.tbl_filter(function(file) return vim.fn.isdirectory(file) == 0 end, files)
  table.sort(files)

  local index = vim.fn.index(files, current_file) + 1
  if index == #files or index == 0 then return end
  vim.cmd('e ' .. files[index + 1])
end, { desc = 'Next file' })

-- Clear search and snippet placeholders with <esc>
map('i', '<esc>', '<cmd>noh<cr><esc>', { desc = 'Escape and clear hlsearch' })
map({ 'n', 's' }, '<esc>', function()
  vim.cmd('noh')
  vim.snippet.stop()
  return '<esc>'
end, { expr = true, desc = 'Escape and clear hlsearch/snippet' })

-- Terminal
map('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
map({ 'n', 'v' }, '`', function() require('tuque.term').cycle() end, { desc = 'Cycle terminal' })
map({ 'n', 'i', 't', 'v' }, '<C-`>', function() require('tuque.term').create() end, { desc = 'Create terminal' })

-- https://github.com/mhinz/vim-galre#saner-behavior-of-n-and-n
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next search result' })
map({ 'x', 'o' }, 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next search result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev search result' })
map({ 'x', 'o' }, 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev search result' })

-- quit
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit all' })
map('n', '<leader>qQ', '<cmd>qa!<cr>', { desc = 'Force quit all' })

-- ctrl based commands
map({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })

-- better indenting
map('v', '<', '<gv')
map('v', '>', '>gv')

-- lazy
map('n', '<leader>l', '<cmd>Lazy<cr>', { desc = 'Lazy' })

-- options
map('n', '<leader>uw', '<cmd>set wrap!<cr>', { desc = 'Toggle line wrapping' })
map('n', '<leader>uc', function()
  local value = vim.opt.conceallevel
  vim.opt.conceallevel = value == 0 and 2 or 0
end, { desc = 'Toggle conceal' })

-- diagnostic
local diagnostic_goto = function(count, severity)
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() vim.diagnostic.jump({ count = count, severity = severity }) end
end
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', ']d', diagnostic_goto(1), { desc = 'Next Diagnostic' })
map('n', '[d', diagnostic_goto(-1), { desc = 'Prev Diagnostic' })
map('n', ']e', diagnostic_goto(1, 'ERROR'), { desc = 'Next Error' })
map('n', '[e', diagnostic_goto(-1, 'ERROR'), { desc = 'Prev Error' })
map('n', ']w', diagnostic_goto(1, 'WARN'), { desc = 'Next Warning' })
map('n', '[w', diagnostic_goto(-1, 'WARN'), { desc = 'Prev Warning' })

-- windows
map('n', '<leader>ww', '<C-W>p', { desc = 'Other window' })
map('n', '<leader>wd', '<C-W>c', { desc = 'Delete window' })
map('n', '<leader>wh', '<C-W>s<C-W>j', { desc = 'Split window below' })
map('n', '<leader>wv', '<C-W>v<C-W>l', { desc = 'Split window right' })

-- clipboard
map('v', '<leader>p', '"+p', { desc = 'Paste from clipboard' })
map('n', '<leader>p', '"+p', { desc = 'Paste from clipboard' })
map('v', '<leader>P', '"+P', { desc = 'Paste from clipboard' })
map('n', '<leader>P', '"+P', { desc = 'Paste from clipboard' })
map('v', '<leader>y', '"+y', { desc = 'Yank to clipboard' })
map('v', '<leader>Y', function()
  local curl = require('plenary.curl')
  local strings = require('plenary.strings')
  local filetype_to_extensions = {
    lua = 'lua',
    typescript = 'ts',
    javascript = 'js',
    typescriptreact = 'tsx',
    javascriptreact = 'jsx',
    markdown = 'md',
    json = 'json',
    yaml = 'yaml',
    toml = 'toml',
    html = 'html',
    css = 'css',
    scss = 'scss',
    sass = 'sass',
    less = 'less',
    graphql = 'graphql',
    sql = 'sql',
    vim = 'vim',
    sh = 'sh',
    fish = 'fish',
    zsh = 'zsh',
    bash = 'bash',
    python = 'py',
    rust = 'rs',
    go = 'go',
    java = 'java',
    c = 'c',
    cpp = 'cpp',
    tsx = 'tsx',
    jsx = 'jsx',
    php = 'php',
    ruby = 'rb',
    r = 'r',
    ocaml = 'ml',
    haskell = 'hs',
    scala = 'scala',
    clojure = 'clj',
    elixir = 'ex',
    erlang = 'erl',
    dart = 'dart',
    nim = 'nim',
    purescript = 'purs',
    reason = 're',
    svelte = 'svelte',
    vue = 'vue',
    crystal = 'cr',
    zig = 'zig',
    julia = 'jl',
    racket = 'rkt',
    scheme = 'scm',
    lisp = 'lisp',
    fennel = 'fnl',
    moonscript = 'moon',
    nix = 'nix',
  }

  vim.cmd.normal({ '"zy', bang = true })
  local selected_text = strings.dedent(vim.fn.getreg('z'))

  local response = curl.post('https://paste.super.fish/', {
    method = 'POST',
    body = selected_text,
  })

  local redirect_url = response.body
  local extension = filetype_to_extensions[vim.bo.filetype] or 'txt'
  if redirect_url then
    vim.fn.setreg('+', 'https://paste.super.fish' .. redirect_url .. '.' .. extension)
    vim.notify('Copied to clipboard and system clipboard')
  else
    vim.notify('Failed to upload to pastebin')
  end
end, { desc = 'Upload selection to paste bin' })
