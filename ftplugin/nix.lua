vim.treesitter.start()
vim.lsp.config('nil_ls', {
  settings = {
    ['nil'] = {
      formatting = { command = { 'nixfmt' } },
      nix = {
        maxMemoryMB = 8192, -- memory limit for evaluating inputs
        flake = { autoArchive = true, autoEvalInputs = true },
      },
    },
  },
})
vim.lsp.enable('nil_ls')
