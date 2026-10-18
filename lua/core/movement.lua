local map = require('tuque.utils').map

vim.pack.add({ 'https://github.com/chrisgrieser/nvim-spider' })

-- skip punctuation, subwords
map({ 'n', 'o', 'x' }, 'w', function() require('spider').motion('w') end)
map({ 'n', 'o', 'x' }, 'e', function() require('spider').motion('e') end)
map({ 'n', 'o', 'x' }, 'b', function() require('spider').motion('b') end)
require('spider').setup({ subwordMovement = true })
