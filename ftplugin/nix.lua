vim.treesitter.start()
vim.lsp.config('nil_ls', { settings = { ['nil'] = { formatting = { command = { 'nixfmt' } } } } })
vim.lsp.enable('nil_ls')
