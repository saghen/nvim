local map = require('tuque.utils').map

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/kkharji/sqlite.lua',
  { src = 'https://github.com/danielfalk/smart-open.nvim', version = '0.3.x' },
})

map(
  'n',
  '<leader>/',
  function()
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
      winblend = 10,
      previewer = false,
    }))
  end,
  { desc = 'Search Current Buffer' }
)

map('n', '<leader>.', '<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>', { desc = 'Buffers' })
map('n', '<leader>:', '<cmd>Telescope command_history<cr>', { desc = 'Command History' })
map('n', "<leader>'", '<cmd>Telescope registers<cr>', { desc = 'Registers' })
map('n', '<leader>y', '<cmd>Telescope lsp_document_symbols<cr>', { desc = 'Goto Symbol' })
map('n', '<leader>r', '<cmd>Telescope resume<cr>', { desc = 'Resume last search' })

-- find
map('n', '<leader>ff', '<cmd>Telescope git_files<cr>', { desc = 'Find Git Files' })
map('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = 'Recent' })
map(
  'n',
  '<leader>fc',
  '<cmd>lua require("telescope.builtin").find_files({ cwd = "~/.config" })<cr>',
  { desc = 'Find .config file' }
)

-- git
map('n', '<leader>sgc', '<cmd>Telescope git_commits<cr>', { desc = 'commits' })
map('n', '<leader>sgs', '<cmd>Telescope git_status<cr>', { desc = 'status' })

-- search
map('n', '<leader>sa', '<cmd>Telescope autocommands<cr>', { desc = 'Auto Commands' })
map('n', '<leader>sb', '<cmd>Telescope current_buffer_fuzzy_find<cr>', { desc = 'Buffer' })
map('n', '<leader>sc', '<cmd>Telescope command_history<cr>', { desc = 'Command History' })
map('n', '<leader>sC', '<cmd>Telescope commands<cr>', { desc = 'Commands' })
map('n', '<leader>sd', '<cmd>Telescope diagnostics bufnr=0<cr>', { desc = 'Document diagnostics' })
map('n', '<leader>sD', '<cmd>Telescope diagnostics<cr>', { desc = 'Workspace diagnostics' })
map(
  'n',
  ',',
  function()
    require('telescope.builtin').live_grep({
      additional_args = { '--glob=!package-lock.json', '--glob=!Cargo.lock', '--glob=!go.mod' },
    })
  end,
  { desc = 'Grep' }
)
map('n', '<leader>sh', '<cmd>Telescope help_tags<cr>', { desc = 'Help Pages' })
map('n', '<leader>sH', '<cmd>Telescope highlights<cr>', { desc = 'Search Highlight Groups' })
map('n', '<leader>sk', '<cmd>Telescope keymaps<cr>', { desc = 'Key Maps' })
map('n', '<leader>sM', '<cmd>Telescope man_pages<cr>', { desc = 'Man Pages' })
map('n', '<leader>sm', '<cmd>Telescope marks<cr>', { desc = 'Jump to Mark' })
map(
  'n',
  '<leader>sn',
  function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') }) end,
  { desc = 'Neovim Config' }
)
map('n', '<leader>so', '<cmd>Telescope vim_options<cr>', { desc = 'Options' })
map('n', '<leader>sS', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', { desc = 'Goto Symbol (Workspace)' })
map('n', '<leader>,', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', { desc = 'Goto Symbol (Workspace)' })
map('n', '<leader>cl', '<cmd>Telescope filetypes<cr>', { desc = 'Pick Language' })
-- local resolve = require('telescope.resolve')
local actions = require('telescope.actions')
require('telescope').setup({
  defaults = {
    preview = {
      treesitter = {
        -- disable for languages where the semantic highlighting is good enough
        -- since it adds stutter on every buffer load
        disable = { 'javascript', 'typescript', 'typescriptreact', 'javascriptreact', 'nix' },
      },
    },

    scroll_strategy = 'limit', -- don't rollover when scrolling
    sorting_strategy = 'ascending', -- show best result at the top
    layout_strategy = 'center',
    layout_config = {
      prompt_position = 'top',
      scroll_speed = 4,
      center = { width = 110 },
    },

    prompt_prefix = '  ',
    selection_caret = ' ',
    entry_prefix = ' ',
    border = true,
    borderchars = {
      prompt = { '─', '│', '─', '│', '┌', '┐', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
      preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    },
    preview_title = false, -- disable
    results_title = false, -- disable

    -- open in the first window that isnt incline
    get_selection_window = function()
      local wins = vim.api.nvim_list_wins()
      table.insert(wins, 1, vim.api.nvim_get_current_win())
      for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local filetype = vim.bo[buf].filetype
        if filetype ~= 'incline' then return win end
      end
      return 0
    end,
    file_ignore_patterns = { 'node_modules' },
    mappings = {
      i = {
        ['<C-Left>'] = actions.cycle_history_prev,
        ['<C-Right>'] = actions.cycle_history_next,
        ['<C-Up>'] = actions.preview_scrolling_up,
        ['<C-Down>'] = actions.preview_scrolling_down,
      },
      n = {
        ['q'] = actions.close,
      },
    },
  },
})

-- smarter file opening
map(
  'n',
  '<CR>',
  function() require('telescope').extensions.smart_open.smart_open({ cwd_only = true }) end,
  { desc = 'Files' }
)
require('telescope').load_extension('smart_open')
