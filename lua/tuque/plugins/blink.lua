local map = require('tuque.utils').map

map('n', '<leader>bf', function() require('blink.lib.bench').run_file() end, { desc = 'Run benchmarks (current file)' })
map('n', '<leader>br', function() require('blink.lib.bench').run_files() end, { desc = 'Run benchmarks' })

require('blink.indent').setup({ dedent_scoped_filetypes = true })

require('blink.pairs').build({ dev = true })
require('blink.pairs').setup({})

require('blink.cmp').build({ dev = true })
require('blink.cmp').setup({
  keymap = {
    preset = 'super-tab',
    ['<C-g>'] = { 'accept' },
    ['<C-d>'] = { 'select_next' },
    ['<C-c>'] = { 'select_prev' },
  },
  appearance = { nerd_font_variant = 'normal' },
  signature = { enabled = true },
  cmdline = { enabled = false },
})
