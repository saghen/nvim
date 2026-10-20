local map = require('tuque.utils').map

vim.pack.add({
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/Wansmer/treesj',
})

-- mini
map('n', '<leader>bd', function() require('mini.bufremove').delete(0) end, { desc = 'Delete Buffer' })
map('n', '<leader>bD', function() require('mini.bufremove').delete(0, true) end, { desc = 'Delete Buffer (Force)' })
require('mini.ai').setup({ custom_textobjects = { g = require('mini.extra').gen_ai_spec.buffer() } })
require('mini.cursorword').setup({ delay = 400 })
require('mini.surround').setup({ n_lines = 50 }) -- number of lines to search
require('mini.icons').setup()

-- treesj
map('n', 'gm', '<cmd>TSJToggle<cr>', { desc = 'Toggle Block' })
require('treesj').setup({ use_default_keymaps = false, max_join_length = 1000 })
