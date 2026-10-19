local map = require('tuque.utils').map

map('n', '<leader>bd', function() require('mini.bufremove').delete(0) end, { desc = 'Delete Buffer' })
map('n', '<leader>bD', function() require('mini.bufremove').delete(0, true) end, { desc = 'Delete Buffer (Force)' })
require('mini.ai').setup()
require('mini.icons').setup()
MiniIcons.mock_nvim_web_devicons()
require('mini.cursorword').setup({ delay = 400 })
require('mini.surround').setup({ n_lines = 50 }) -- number of lines to search

map('n', 'gm', '<cmd>TSJToggle<cr>', { desc = 'Toggle Block' })
require('treesj').setup({ use_default_keymap = false, max_join_length = 1000 })

-- edit the filesystem like a buffer
map('n', '<leader>e', '<cmd>Oil<cr>', { desc = 'Open parent directory' })
map('n', '<leader>E', function() require('oil').open(vim.fn.getcwd()) end, { desc = 'Open working directory' })

require('oil').setup({
  keymaps = {
    ['`'] = false,
    ['~'] = { 'actions.cd', mode = 'n' },
    ['<C-s>'] = false,
    ['<C-p>'] = { 'actions.preview', opts = { split = 'belowright' } },
    ['<C-l>'] = false,
    ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
    ['<C-h>'] = false,
    ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
  },
  win_options = { winbar = '%!v:lua.tuque_oil_winbar()' },
  delete_to_trash = true,
  watch_for_changes = true,
  skip_confirm_for_simple_edits = true,
  cleanup_delay_ms = 600000, -- 10 mins
  lsp_file_methods = { autosave_changes = true },
  git = {
    mv = function() return true end,
    rm = function() return true end,
  },
})

-- keybind hints below the last entry
local oil_hints_ns = vim.api.nvim_create_namespace('tuque.oil_hints')
local oil_hints = {
  {},
  { { '<CR> open  - parent  _ cwd  ~ cd  g. hidden', 'Comment' } },
  { { '<C-s> apply  <C-p> preview  <C-v> vsplit  gx external  g? help', 'Comment' } },
}
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'oil',
  callback = function(args)
    local function draw()
      if not vim.api.nvim_buf_is_valid(args.buf) then return end
      vim.api.nvim_buf_clear_namespace(args.buf, oil_hints_ns, 0, -1)
      local last = vim.api.nvim_buf_line_count(args.buf) - 1
      vim.api.nvim_buf_set_extmark(args.buf, oil_hints_ns, last, 0, { virt_lines = oil_hints })
    end
    draw()
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, { buffer = args.buf, callback = draw })
  end,
})

-- current directory in the winbar, with the part inside cwd highlighted
function _G.tuque_oil_winbar()
  local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require('oil').get_current_dir(buf)
  if dir == nil then return '' end

  local cwd = vim.fn.getcwd(vim.g.statusline_winid) .. '/'
  local path = vim.fn.fnamemodify(dir, ':~')
  local dim, bright
  if dir == cwd then
    dim, bright = path:match('^(.-)([^/]+/)$')
  elseif vim.startswith(dir, cwd) then
    dim = vim.fn.fnamemodify(cwd, ':~')
    bright = path:sub(#dim + 1)
  else
    dim, bright = path, ''
  end

  local icon, icon_hl = MiniIcons.get('directory', dir)
  local function escape(str) return (str:gsub('%%', '%%%%')) end
  return (vim.bo[buf].modified and '%#BufferCurrentMod#● ' or '')
    .. ('%#' .. icon_hl .. '#' .. icon .. ' ')
    .. ('%#Comment#' .. escape(dim))
    .. ('%#Normal#' .. escape(bright))
end
