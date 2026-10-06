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
        workspaceRoots = vim.api.nvim_list_runtime_paths(),
        ignoreGlobs = { '**/*_spec.lua', '**/test_*.lua', '**/mini.nvim/**' },
      },
    },
  },
})
vim.lsp.enable('emmylua_ls')
