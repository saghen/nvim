-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = '-'

opt.completeopt = 'menu,menuone,preview'
opt.clipboard = ''

opt.conceallevel = 2 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs

opt.list = true -- Show some invisible characters (tabs...
opt.number = true -- Print line number
opt.pumblend = 0 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.showmode = false -- We have a status line and modicator
opt.signcolumn = 'yes' -- Always show the signcolumn, otherwise it would shift the text each time
opt.ignorecase = true -- Ignore case when searching, unless there's a capital with flash.nvim
opt.scroll = 4 -- Lines to scroll for <C-u> and <C-d>
opt.scrolloff = 4 -- Minimal number of screen lines to keep above and below the cursor
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { 'en' }
opt.termguicolors = true -- True color support
opt.undofile = true
-- Maximum number of changes that can be undone, large values increase file loading time:
-- https://www.reddit.com/r/neovim/comments/1gq17re/a_large_undolevel_will_slow_down_buffer_loading
opt.undolevels = 500
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.wrap = true -- Line wrapping

opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for
vim.api.nvim_create_autocmd('FileType', { -- doesn't apply to markdown by default for some reason
  pattern = 'markdown',
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

if os.getenv('NVIM_DEV') ~= nil then
  opt.swapfile = false
  opt.shada = ''
end

-- folds
vim.o.foldcolumn = '0'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- don't show the neovim dashboard
opt.shortmess:append('I')

-- statusline
opt.cmdheight = 0
opt.laststatus = 0

-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
opt.splitkeep = 'screen'

opt.list = true
opt.listchars:append('space: ')
opt.listchars:append('trail:⋅')
opt.fillchars = {
  fold = ' ', -- or "⸱"
  foldopen = '',
  foldclose = '',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',

  -- controls the border around windows
  vert = ' ',
  horiz = ' ',
  horizup = ' ',
  horizdown = ' ',
}

opt.mouse = 'a'
opt.mousemoveevent = true

opt.guifont = 'IosevkaCustom Nerd Font:h17'

-- Support for semantic higlighting https://github.com/neovim/neovim/pull/21100
g.lsp_semantic_enabled = 1

if g.neovide then
  opt.linespace = 8

  g.neovide_scale_factor = 1.0
  g.neovide_floating_shadow = false

  g.neovide_underline_stroke_scale = 2

  g.neovide_cursor_trail_size = 0.05
  g.neovide_cursor_animation_length = 0.05
  g.neovide_cursor_short_animation_length = 0.02

  g.neovide_scroll_animation_length = 0.05 -- 0.1 to enable, 0 to disable

  g.neovide_position_animation_length = 0 -- window animations

  -- https://github.com/neovide/neovide/issues/1325#issuecomment-1281570219
  -- g.neovide_font_hinting = 'none'
  -- g.neovide_font_edging = 'subpixelantialias'
end
