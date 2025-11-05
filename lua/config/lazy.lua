vim.loader.enable()

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

if os.getenv('NVIM_LATENCY') ~= nil then require('config.autocmds.latency') end

require('config.profiler')
require('config.options')
require('config.autocmds')
require('tuque.buffer-history')

local spec = {
  { import = 'core' },
  { import = 'langs' },
}
if os.getenv('NVIM_DEV') ~= nil or os.getenv('NVIM_PROFILE') ~= nil then table.insert(spec, { import = 'dev' }) end

require('lazy').setup({
  spec = spec,
  defaults = {
    lazy = false, -- whether to lazy load all plugins by default
    version = false, -- default to latest git commit
  },
  rocks = { hererocks = false },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  -- don't automatically check for plugin updates
  checker = { enabled = false },
  -- don't reload when config changes
  change_detection = { enabled = false },
  -- any plugins with dev = true will attempt to load from this local path
  dev = { path = '~/code/nvim', fallback = true },
  -- don't load readmes as help entries
  readme = { enabled = false },
})

require('config.keymaps')
require('tuque.term')

vim.lsp.enable('efm')
