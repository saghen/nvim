local map = require('tuque.utils').map

-- magit
map('n', '<leader>g', '<cmd>Neogit kind=replace<cr>', { desc = 'Open Neogit' })
require('neogit').setup({
  -- hides the hints at the top of the status buffer
  disable_hint = true,
  -- don't scope persisted settings on a per-project basis
  use_per_project_settings = false,
  -- the time after which an output console is shown for slow running commands
  console_timeout = 4000,
  auto_show_console = false, -- TODO: breaks the UI for some reason
  -- graph like https://github.com/rbong/vim-flog
  graph_style = 'unicode',

  commit_editor = { kind = 'split' },
  popup = { kind = 'split' },
  log_view = { kind = 'replace' },
  mappings = { commit_editor = { ['<enter>'] = 'Submit', ['<backspace>'] = 'Abort' } },
})
