vim.lsp.config('emmylua_ls', {
  settings = {
    emmylua = {
      runtime = {
        version = 'LuaJIT',
        requirePattern = {
          'lua/?.lua',
          'lua/?/init.lua',
          '?/lua/?.lua',
          '?/lua/?/init.lua',
        },
      },
      workspace = {
        library = { '$VIMRUNTIME', '$HOME/.local/share/nvim/lazy' },
        ignoreGlobs = { '**/*_spec.lua', '**/test_*.lua', '**/mini.nvim/**' },
      },
    },
  },
})
vim.lsp.enable('emmylua_ls')
