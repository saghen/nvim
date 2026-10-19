-- cargo.toml lsp
require('crates').setup({
  lsp = { enabled = true, actions = true, completion = true, hover = true },
  completion = { crates = { enabled = true } },
})
