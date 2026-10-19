vim.loader.enable()
require('vim._core.ui2').enable({ msg = { targets = 'msg' } })

-- disable some rtp plugins
vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zipPlugin = 1

-- nested neovim instances open in the parent
vim.pack.add({ 'https://github.com/willothy/flatten.nvim' })
require('flatten').setup({
  hooks = {
    should_block = function(argv)
      -- adds support for kubectl edit, sops and probably many other tools
      return vim.startswith(argv[#argv], '/tmp') or require('flatten').default_should_block(argv)
    end,
  },
})

require('tuque.options')
require('tuque.autocmds')
require('tuque.keymaps')
require('tuque.buffer-history')
require('tuque.term')
require('tuque.theme')

local utils = require('tuque.utils')
utils.pack_build('nvim-treesitter', function() vim.cmd('TSUpdate') end)
vim.pack.add({
  -- ai
  'https://github.com/theprimeagen/99',
  'https://github.com/supermaven-inc/supermaven-nvim',
  -- coding
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/Wansmer/treesj',
  'https://github.com/stevearc/oil.nvim',
  -- git
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/NeogitOrg/neogit',
  -- lsp
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/Chaitanyabsprip/fastaction.nvim',
  'https://github.com/saecki/live-rename.nvim',
  -- movement
  'https://github.com/chrisgrieser/nvim-spider',
  -- quickfix
  'https://github.com/stevearc/quicker.nvim',
  -- rust
  { src = 'https://github.com/saecki/crates.nvim', version = 'stable' },
  { src = 'https://github.com/mrcjkb/rustaceanvim', version = vim.version.range('*') },
  -- telescope
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/kkharji/sqlite.lua',
  { src = 'https://github.com/danielfalk/smart-open.nvim', version = '0.3.x' },
  -- treesitter
  'https://github.com/nvim-treesitter/nvim-treesitter',
  -- ui
  'https://github.com/saghen/filler-begone.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/b0o/incline.nvim',
})
utils.pack_add_dev({
  'https://github.com/saghen/blink.lib',
  'https://github.com/saghen/blink.indent',
  'https://github.com/saghen/blink.pairs',
  'https://github.com/saghen/blink.cmp',
})

for name in vim.fs.dir(vim.fn.stdpath('config') .. '/lua/tuque/plugins') do
  require('tuque.plugins.' .. name:gsub('%.lua$', ''))
end
