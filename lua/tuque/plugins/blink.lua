require('tuque.utils').pack_add_dev({
  { src = 'https://github.com/saghen/blink.lib', version = 'vim-async' },
  'https://github.com/saghen/blink.indent',
  'https://github.com/saghen/blink.pairs',
  { src = 'https://github.com/saghen/blink.cmp', version = 'in-process-lsp' },
})

require('blink.indent').setup({ dedent_scoped_filetypes = true })

require('blink.pairs').build({ dev = true })
require('blink.pairs').setup({})

require('blink.cmp').build({ dev = true })
require('blink.cmp').setup({
  keymap = {
    preset = 'super-tab',
    ['<C-g>'] = { 'accept', 'fallback' },
    ['<C-d>'] = { 'select_next', 'fallback' },
    ['<C-c>'] = { 'select_prev', 'fallback' },
  },
  appearance = { nerd_font_variant = 'normal' },
  signature = { enabled = true },
  cmdline = { enabled = false },
})
