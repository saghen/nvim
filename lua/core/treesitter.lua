require('tuque.utils').pack_build('nvim-treesitter', function() vim.cmd('TSUpdate') end)
vim.pack.add({ { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' } })
local ts = require('nvim-treesitter')
ts.install({
  'markdown',
  'markdown_inline',
  'html',
  'just',
  'json',
  'nix',
  'python',
  'rust',
  'typescript',
  'tsx',
  'javascript',
  'jsx',
  'terraform',
  'toml',
  'yaml',
})
