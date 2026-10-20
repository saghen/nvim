vim.loader.enable()

-- enable UI2, including in headless servers (where ui attaches later)
local function enable_ui2() require('vim._core.ui2').enable({ msg = { targets = 'msg' } }) end
if #vim.api.nvim_list_uis() > 0 then
  enable_ui2()
else
  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = function()
      enable_ui2()
      -- fires OptionSet so that ui2 picks up cmdheight, since it only reads it before VimEnter
      vim.o.cmdheight = vim.o.cmdheight
    end,
  })
end

-- nested neovim instances open in the parent
vim.pack.add({ 'https://github.com/willothy/flatten.nvim' })
require('flatten').setup({
  -- adds support for kubectl edit, sops and probably many other tools
  hooks = { should_block = function(argv) return vim.startswith(argv[#argv], '/tmp') end },
})

-- disable some rtp plugins
vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_nvim_zip_plugin = 1

require('tuque.options')
require('tuque.autocmds')
require('tuque.keymaps')
require('tuque.buffer-history')
require('tuque.term')
require('tuque.theme')

for name in vim.fs.dir(vim.fn.stdpath('config') .. '/lua/tuque/plugins') do
  require('tuque.plugins.' .. name:gsub('%.lua$', ''))
end
