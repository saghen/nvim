local opt = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = '\\'

opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs

opt.number = true -- Print line number
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.showmode = false -- The cursor line number is colored by mode instead
opt.signcolumn = 'no' -- Don't show sign column, never used
opt.ignorecase = true -- Ignore case when searching
opt.scrolloff = 4 -- Minimal number of screen lines to keep above and below the cursor
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.splitright = true -- Open vertical splits on the right
opt.splitbelow = true -- Open horizontal splits below
opt.splitkeep = 'screen' -- Keep text in place when a window shrinks/grows
opt.undofile = true
opt.undolevels = 500 -- Too large increases file loading time, keep below 1000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = 'block' -- Allow cursor to move where there is no text in visual block mode
opt.wildoptions:append('fuzzy') -- Use fuzzy matching for command line completion

opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for
g.markdown_recommended_style = 0 -- Otherwise markdown uses 4 spaces

if os.getenv('NVIM_DEV') ~= nil then
  opt.swapfile = false
  opt.shada = ''
end

-- folds
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- statusline
opt.cmdheight = 0
opt.laststatus = 0

opt.list = true
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
