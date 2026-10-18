local map = require('tuque.utils').map

-- convert git branches/files to remote URLs
vim.pack.add({ 'https://github.com/linrongbin16/gitlinker.nvim' })
map({ 'n', 'v' }, '<leader>Gyf', '<cmd>GitLink<cr>', { desc = 'Copy file url' })
map({ 'n', 'v' }, '<leader>Gxf', '<cmd>GitLink!', { desc = 'Open file in browser' })

map({ 'n', 'v' }, '<leader>Gxb', '<cmd>GitLink current_branch<cr>', { desc = 'Open branch in browser' })
map({ 'n', 'v' }, '<leader>Gyb', '<cmd>GitLink current_branch<cr>', { desc = 'Copy branch url' })

map({ 'n', 'v' }, '<leader>Gxr', '<cmd>GitLink! default_branch<cr>', { desc = 'Open repo in browser' })
map({ 'n', 'v' }, '<leader>Gyr', '<cmd>GitLink default_branch<cr>', { desc = 'Copy repo url' })

map({ 'n', 'v' }, '<leader>GxB', '<cmd>GitLink! blame<cr>', { desc = 'Open blame in browser' })
require('gitlinker').setup({})

-- telescope pickers
vim.pack.add({
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/linrongbin16/gitlinker.nvim',
  'https://github.com/aaronhallaert/advanced-git-search.nvim',
})
map('n', '<leader>sgl', '<cmd>AdvancedGitSearch search_log_content_file<cr>', { desc = 'Search log content (file)' })
map('n', '<leader>sgL', '<cmd>AdvancedGitSearch search_log_content<cr>', { desc = 'Search log content (repo)' })
map('n', '<leader>sgdf', '<cmd>AdvancedGitSearch diff_commit_file<cr>', { desc = 'Diff with commit (file)' })
map('n', '<leader>sgdb', '<cmd>AdvancedGitSearch diff_branch_file', { desc = 'Diff with branch (file)' })
map('n', '<leader>sgdl', '<cmd>AdvancedGitSearch diff_commit_line', { desc = 'Diff with commit (line)' })
map('n', '<leader>sgb', '<cmd>AdvancedGitSearch changed_on_branch<cr>', { desc = 'Changed on branch' })
map('n', '<leader>sgc', '<cmd>AdvancedGitSearch checkout_reflog<cr>', { desc = 'Checkout via reflog' })
map('n', '<leader>sgg', '<cmd>AdvancedGitSearch show_custom_functions<cr>', { desc = 'Pick a picker' })
require('telescope').setup({
  extensions = {
    advanced_git_search = {
      show_builtin_git_pickers = true, -- show builtin pickers for show_custom_functions
      browse_command = 'GitLink! rev={commit_hash}',
      diff_plugin = 'diffview',
    },
  },
})
require('telescope').load_extension('advanced_git_search')

-- main client
vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/sindrets/diffview.nvim',
  'https://github.com/NeogitOrg/neogit',
})
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
