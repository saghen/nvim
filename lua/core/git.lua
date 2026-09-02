return {
  -- convert git branches/files to remote URLs
  {
    'linrongbin16/gitlinker.nvim',
    cmd = 'GitLink',
    keys = {
      { '<leader>Gyf', '<cmd>GitLink<cr>', mode = { 'n', 'v' }, desc = 'Copy file url' },
      { '<leader>Gxf', '<cmd>GitLink!', mode = { 'n', 'v' }, desc = 'Open file in browser' },

      { '<leader>Gxb', '<cmd>GitLink current_branch<cr>', mode = { 'n', 'v' }, desc = 'Open branch in browser' },
      { '<leader>Gyb', '<cmd>GitLink current_branch<cr>', mode = { 'n', 'v' }, desc = 'Copy branch url' },

      { '<leader>Gxr', '<cmd>GitLink! default_branch<cr>', mode = { 'n', 'v' }, desc = 'Open repo in browser' },
      { '<leader>Gyr', '<cmd>GitLink default_branch<cr>', mode = { 'n', 'v' }, desc = 'Copy repo url' },

      { '<leader>GxB', '<cmd>GitLink! blame<cr>', mode = { 'n', 'v' }, desc = 'Open blame in browser' },
    },
    opts = {},
  },

  -- telescope pickers
  {
    'aaronhallaert/advanced-git-search.nvim',
    cmd = 'AdvancedGitSearch',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'sindrets/diffview.nvim',
      'linrongbin16/gitlinker.nvim',
    },
    keys = {
      { '<leader>sgl', '<cmd>AdvancedGitSearch search_log_content_file<cr>', desc = 'Search log content (file)' },
      { '<leader>sgL', '<cmd>AdvancedGitSearch search_log_content<cr>', desc = 'Search log content (repo)' },
      { '<leader>sgdf', '<cmd>AdvancedGitSearch diff_commit_file<cr>', desc = 'Diff with commit (file)' },
      { '<leader>sgdb', '<cmd>AdvancedGitSearch diff_branch_file', 'Diff with branch (file)' },
      { '<leader>sgdl', '<cmd>AdvancedGitSearch diff_commit_line', 'Diff with commit (line)' },
      { '<leader>sgb', '<cmd>AdvancedGitSearch changed_on_branch<cr>', desc = 'Changed on branch' },
      { '<leader>sgc', '<cmd>AdvancedGitSearch checkout_reflog<cr>', desc = 'Checkout via reflog' },
      { '<leader>sgg', '<cmd>AdvancedGitSearch show_custom_functions<cr>', desc = 'Pick a picker' },
    },
    config = function()
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
    end,
  },

  -- main client
  {
    'saghen/neogit',
    branch = 'configurable-popup-kind',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'sindrets/diffview.nvim',
    },
    command = { 'Neogit', 'NeogitCommit', 'NeogitLogCurrent', 'NeogitResetState' },
    keys = {
      -- NOTE: use `b o` in neogit to open PR
      { '<leader>g', '<cmd>Neogit kind=replace<cr>', desc = 'Open Neogit' },
    },
    opts = {
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

      commit_view = { kind = 'replace' },
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
    },
  },
}
