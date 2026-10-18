vim.pack.add({
  { src = 'https://github.com/saecki/crates.nvim', version = 'stable' },
  -- LSP, code actions and a bunch more
  { src = 'https://github.com/mrcjkb/rustaceanvim', version = vim.version.range('*') },
})

-- autocomplete for cargo.toml
require('crates').setup({
  lsp = {
    enabled = true,
    actions = true,
    completion = true,
    hover = true,
  },
  completion = {
    crates = { enabled = true },
  },
})
