local utils = require('tuque.utils')
local map = utils.map

utils.pack_build('blink.cmp', function() require('blink.cmp').build():pwait() end)
utils.pack_add_dev({
  'https://github.com/saghen/blink.lib',
  'https://github.com/saghen/blink.indent',
  { src = 'https://github.com/saghen/blink.pairs', version = vim.version.range('*') },
  'https://github.com/saghen/blink.cmp',
  'https://github.com/saghen/blink.nvim',
})

map('n', '<leader>bf', function() require('blink.lib.bench').run_file() end, { desc = 'Run benchmarks (current file)' })
map('n', '<leader>br', function() require('blink.lib.bench').run_files() end, { desc = 'Run benchmarks' })

require('blink.indent').setup({ dedent_scoped_filetypes = true })

require('blink.pairs').download():pwait()
--- @module 'blink.pairs'
--- @type blink.pairs.Config
require('blink.pairs').setup({})

--- @module 'blink.cmp'
--- @type blink.cmp.Config
require('blink.cmp').setup({
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
})

-- chartoggle
map(
  { 'i', 'n', 'v' },
  '<C-;>',
  function() require('blink.chartoggle').toggle_char_eol(';') end,
  { desc = 'Toggle ; at eol' }
)
map('v', ',', function() require('blink.chartoggle').toggle_char_eol(',') end, { desc = 'Toggle , at eol' })
map(
  { 'i', 'n' },
  '<C-,>',
  function() require('blink.chartoggle').toggle_char_eol(',') end,
  { desc = 'Toggle , at eol' }
)

-- select
map('n', '<leader>mb', function() require('blink.select').show('buffers') end, { desc = 'Select buffer' })
map('n', '<leader>md', function() require('blink.select').show('diagnostics') end, { desc = 'Select diagnostic' })
map(
  'n',
  '<leader>mc',
  function() require('blink.select').show('recent-commands') end,
  { desc = 'Select recent commands' }
)
map('n', '<leader>ms', function() require('blink.select').show('symbols') end, { desc = 'Select symbol' })
map('n', '<leader>my', function() require('blink.select').show('yank-history') end, { desc = 'Select yank history' })
map('n', '<leader>m/', function() require('blink.select').show('recent-searches') end, { desc = 'Select search' })
map('n', '<leader>ma', function() require('blink.select').show('code-actions') end, { desc = 'Select code action' })
map('n', '<leader>mo', function() require('blink.select').show('smart-open') end, { desc = 'Select code action' })

require('blink').setup({
  chartoggle = { enabled = true },
  select = {
    enabled = true,
    mapping = {
      selection = { 'm', 'n', 'e', 'i', 'a', 'r', 's', 't' },
    },
  },
})
