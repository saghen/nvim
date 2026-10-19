local map = require('tuque.utils').map

local quicker = require('quicker')

map('n', '<leader>q', function() quicker.toggle() end, { desc = 'Quickfix' })
map('n', '<leader>l', function() quicker.toggle({ loclist = true }) end, { desc = 'Loclist' })

quicker.setup({})
