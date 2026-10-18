vim.loader.enable()

-- disable some rtp plugins
vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_2html_plugin = 1 -- tohtml
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_zipPlugin = 1

require('config.profiler')
require('config.options')
require('config.autocmds')
require('tuque.buffer-history')

local function import(module)
  for _, path in ipairs(vim.api.nvim_get_runtime_file('lua/' .. module .. '/*.lua', true)) do
    require(module .. '.' .. vim.fn.fnamemodify(path, ':t:r'))
  end
end

-- flatten.nvim must load before any other plugin, followed by the colorscheme
require('core.terminal')
require('core.theme')
import('core')
import('langs')
if os.getenv('NVIM_DEV') ~= nil or os.getenv('NVIM_PROFILE') ~= nil then import('dev') end

require('config.keymaps')
require('tuque.term')
