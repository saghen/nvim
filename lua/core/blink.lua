return {
  {
    'saghen/blink.ai',
    dev = true,
    --- @module 'blink.ai'
    --- @type blink.ai.Config
    opts = {
      adapters = {
        anthropic = {
          api_key = function() return vim.g.ANTHROPIC_API_KEY end,
        },
      },
    },
  },

  {
    'saghen/blink.lib',
    keys = {
      { '<leader>bf', function() require('blink.lib.bench').run_file() end, desc = 'Run benchmarks (current file)' },
      { '<leader>br', function() require('blink.lib.bench').run_files() end, desc = 'Run benchmarks' },
    },
    dev = true,
  },
  { 'saghen/blink.indent', dev = true },
  {
    'saghen/blink.pairs',
    dev = true,
    --- @module 'blink.pairs'
    --- @type blink.pairs.Config
    opts = {},
  },

  {
    'saghen/blink.cmp',
    dev = true,
    build = function() require('blink.cmp').build() end,
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'super-tab',
        ['<C-g>'] = { 'accept' },
        ['<C-d>'] = { 'select_next' },
        ['<C-c>'] = { 'select_prev' },
        ['<C-n>'] = { 'select_next', 'show_and_insert' },
      },
      appearance = {
        nerd_font_variant = 'normal',
        use_nvim_cmp_as_default = true,
      },
      sources = { default = { 'lsp', 'path', 'buffer' } },

      cmdline = {
        keymap = {
          preset = 'inherit',
          ['<Tab>'] = { 'show', 'accept', 'fallback' },
        },
        completion = {
          menu = { auto_show = true },
          ghost_text = { enabled = false },
        },
      },

      signature = { enabled = true, window = { show_documentation = false } },
    },
    opts_extend = { 'sources.default' },
  },

  {
    'saghen/blink.nvim',
    dev = true,
    lazy = false,
    keys = {
      -- chartoggle
      {
        '<C-;>',
        function() require('blink.chartoggle').toggle_char_eol(';') end,
        mode = { 'i', 'n', 'v' },
        desc = 'Toggle ; at eol',
      },
      {
        ',',
        function() require('blink.chartoggle').toggle_char_eol(',') end,
        mode = 'v',
        desc = 'Toggle , at eol',
      },
      {
        '<C-,>',
        function() require('blink.chartoggle').toggle_char_eol(',') end,
        mode = { 'i', 'n' },
        desc = 'Toggle , at eol',
      },
      {
        '<C-,>',
        function() require('blink.chartoggle').toggle_char_eol(',') end,
        mode = 'i',
        desc = 'Toggle , at eol',
      },

      -- select
      {
        '<leader>mb',
        function() require('blink.select').show('buffers') end,
        desc = 'Select buffer',
      },
      {
        '<leader>md',
        function() require('blink.select').show('diagnostics') end,
        desc = 'Select diagnostic',
      },
      {
        '<leader>mc',
        function() require('blink.select').show('recent-commands') end,
        desc = 'Select recent commands',
      },
      {
        '<leader>ms',
        function() require('blink.select').show('symbols') end,
        desc = 'Select symbol',
      },
      {
        '<leader>my',
        function() require('blink.select').show('yank-history') end,
        desc = 'Select yank history',
      },
      {
        '<leader>m/',
        function() require('blink.select').show('recent-searches') end,
        desc = 'Select search',
      },
      {
        '<leader>ma',
        function() require('blink.select').show('code-actions') end,
        desc = 'Select code action',
      },
      {
        '<leader>mo',
        function() require('blink.select').show('smart-open') end,
        desc = 'Select code action',
      },

      -- tree
      { '<leader>E', '<cmd>BlinkTree reveal<cr>', desc = 'Reveal current file in tree' },
      { '<leader>e', '<cmd>BlinkTree toggle-focus<cr>', desc = 'Toggle file tree window or focus' },
    },
    opts = {
      chartoggle = { enabled = true },
      select = {
        enabled = true,
        mapping = {
          selection = { 'm', 'n', 'e', 'i', 'a', 'r', 's', 't' },
        },
      },
      tree = { enabled = true },
    },
  },
}
