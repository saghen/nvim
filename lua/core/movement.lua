local map = require('tuque.utils').map

-- skip punctuation, subwords
vim.pack.add({ 'https://github.com/chrisgrieser/nvim-spider' })
map({ 'n', 'o', 'x' }, 'w', function() require('spider').motion('w') end)
map({ 'n', 'o', 'x' }, 'e', function() require('spider').motion('e') end)
map({ 'n', 'o', 'x' }, 'b', function() require('spider').motion('b') end)
require('spider').setup({ subwordMovement = true })

vim.pack.add({ 'https://github.com/folke/flash.nvim' })
-- stylua: ignore start
map({ "n", "x", "o" }, "S", function() require("flash").jump() end, { desc = "Flash" })
map({ "n", "x", "o" }, "R", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
-- stylua: ignore end
require('flash').setup({})
