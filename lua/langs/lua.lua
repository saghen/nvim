vim.lsp.enable('emmylua_ls')

return {
  -- LSP
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = {
      {
        'saghen/blink.cmp',
        opts = {
          sources = {
            default = { 'lazydev' },
            providers = {
              lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', fallbacks = { 'lsp' } },
            },
          },
        },
      },
    },
    opts = {},
  },
}
