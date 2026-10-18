-- nested neovim instances open in the parent
if os.getenv('NVIM_DEV') == nil then
  vim.pack.add({ { src = 'https://github.com/willothy/flatten.nvim', version = vim.version.range('*') } })
  require('flatten').setup({
    callbacks = {
      should_block = function(argv)
        -- adds support for kubectl edit, sops and probably many other tools
        return vim.startswith(argv[#argv], '/tmp') or require('flatten').default_should_block(argv)
      end,
    },
    window = { open = 'smart' },
  })
end
