return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  branch = 'main',
  config = function()
    local ts = require('nvim-treesitter')
    ts.install({ 'markdown', 'markdown_inline', 'html', 'json', 'nix', 'python', 'rust', 'terraform', 'toml', 'yaml' })
  end,
}
