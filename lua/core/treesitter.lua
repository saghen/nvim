return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  branch = 'main',
  config = function()
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
  end,
}
