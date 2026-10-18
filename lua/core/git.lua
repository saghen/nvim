local map = require('tuque.utils').map

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/linrongbin16/gitlinker.nvim',
  'https://github.com/NeogitOrg/neogit',
})

-- convert git branches/files to remote URLs
map({ 'n', 'v' }, '<leader>Gyf', '<cmd>GitLink<cr>', { desc = 'Copy file url' })
map({ 'n', 'v' }, '<leader>Gxf', '<cmd>GitLink!<cr>', { desc = 'Open file in browser' })

map({ 'n', 'v' }, '<leader>Gxb', '<cmd>GitLink current_branch<cr>', { desc = 'Open branch in browser' })
map({ 'n', 'v' }, '<leader>Gyb', '<cmd>GitLink current_branch<cr>', { desc = 'Copy branch url' })

map({ 'n', 'v' }, '<leader>Gxr', '<cmd>GitLink! default_branch<cr>', { desc = 'Open repo in browser' })
map({ 'n', 'v' }, '<leader>Gyr', '<cmd>GitLink default_branch<cr>', { desc = 'Copy repo url' })

map({ 'n', 'v' }, '<leader>GxB', '<cmd>GitLink! blame<cr>', { desc = 'Open blame in browser' })
require('gitlinker').setup({})

-- main client
-- NOTE: use `b o` in neogit to open PR
map('n', '<leader>g', '<cmd>Neogit kind=replace<cr>', { desc = 'Open Neogit' })
require('neogit').setup({
  -- Hides the hints at the top of the status buffer
  disable_hint = true,
  -- TODO: seems neat but causes weird flickering with cmdheight=0
  process_spinner = false,
  -- don't scope persisted settings on a per-project basis
  use_per_project_settings = false,
  -- the time after which an output console is shown for slow running commands
  console_timeout = 4000,
  auto_show_console = false, -- TODO: breaks the UI for some reason
  -- graph like https://github.com/rbong/vim-flog
  graph_style = 'unicode',

  commit_editor = { kind = 'split' },
  popup = { kind = 'split' },
  mappings = {
    commit_editor = {
      ['<enter>'] = 'Submit',
      ['<backspace>'] = 'Abort',
    },
    status = {
      ['<cr>'] = false,
      ['<leader><cr>'] = 'GoToFile',
    },
  },
})
