vim.treesitter.start()

-- default detection doesnt work on new files
vim.filetype.add({ extension = { tf = 'terraform' } })

-- TODO: freezes editor in abyss
-- vim.lsp.enable('terraformls')
vim.lsp.enable('tflint')
