require('nvim-treesitter').install('go')
vim.treesitter.start()
vim.lsp.enable('gopls')
