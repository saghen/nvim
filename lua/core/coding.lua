local map = require('tuque.utils').map

vim.pack.add({
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/Wansmer/treesj',
})

map('n', '<leader>bd', function()
  local bd = require('mini.bufremove').delete
  if vim.bo.modified then
    local choice = vim.fn.confirm(('Save changes to %q?'):format(vim.fn.bufname()), '&Yes\n&No\n&Cancel')
    if choice == 1 then -- Yes
      vim.cmd.write()
      bd(0)
    elseif choice == 2 then -- No
      bd(0, true)
    end
  else
    bd(0)
  end
end, { desc = 'Delete Buffer' })
map('n', '<leader>bD', function() require('mini.bufremove').delete(0, true) end, { desc = 'Delete Buffer (Force)' })
map('n', '<leader>tt', function() require('mini.test').run() end, { desc = 'Test File' })
map('n', '<leader>tf', function() require('mini.test').run_file() end, { desc = 'Test File' })
map('n', '<leader>tl', function() require('mini.test').run_at_location() end, { desc = 'Test Suite' })
require('mini.ai').setup()
require('mini.cursorword').setup({ delay = 400 })
require('mini.surround').setup({ n_lines = 50 }) -- number of lines to search
require('mini.test').setup()

map('n', 'gm', '<cmd>TSJToggle<cr>', { desc = 'Toggle Block' })
require('treesj').setup({ use_default_keymap = false, max_join_length = 1000 })
