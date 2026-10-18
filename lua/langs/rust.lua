-- autocomplete for cargo.toml
vim.pack.add({ { src = 'https://github.com/saecki/crates.nvim', version = 'stable' } })
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

-- LSP, code actions and a bunch more
vim.pack.add({ { src = 'https://github.com/mrcjkb/rustaceanvim', version = vim.version.range('*') } })
