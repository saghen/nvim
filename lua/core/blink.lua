return {
  {
    'saghen/blink.pick',
    dev = true,
    lazy = false,
    keys = {
      {
        '<leader>bp',
        function() require('blink.pick').open_window() end,
        desc = 'Pick',
      },
    },
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
    dependencies = 'yus-works/csc.nvim',
    dev = true,
    -- version = vim.fn.getenv('BLINK_VERSION') or false,
    -- dev = vim.fn.getenv('BLINK_VERSION') == vim.NIL,
    build = 'cargo build --release',
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'super-tab',
        ['<C-g>'] = { 'accept' },
        ['<C-d>'] = { 'select_next' },
        ['<C-c>'] = { 'select_prev' },
      },
      appearance = {
        nerd_font_variant = 'normal',
        use_nvim_cmp_as_default = true,
      },
      completion = {
        accept = {
          auto_brackets = { semantic_token_resolution = { blocked_filetypes = { 'typescriptreact', 'typescript' } } },
        },
      },
      sources = { default = { 'lsp', 'path' } },
      fuzzy = {
        implementation = 'rust',
        prebuilt_binaries = { ignore_version_mismatch = true },
      },

      cmdline = {
        keymap = {
          preset = 'inherit',
          ['<Tab>'] = { 'show', 'accept', 'fallback' },
        },
        completion = { menu = { auto_show = true }, ghost_text = { enabled = false } },
      },

      -- snippets = { preset = 'luasnip' },

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
