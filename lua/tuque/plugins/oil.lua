local map = require('tuque.utils').map

-- edit the filesystem like a buffer
vim.pack.add({ 'https://github.com/stevearc/oil.nvim' })

map('n', '_', '<cmd>Oil<cr>', { desc = 'Open parent directory' })

require('oil').setup({
  keymaps = {
    ['`'] = false,
    ['~'] = { 'actions.cd', mode = 'n' },
    ['<C-s>'] = false,
    ['<C-p>'] = { 'actions.preview', opts = { split = 'belowright' } },
    ['<C-v>'] = { 'actions.select', opts = { vertical = true } },
    ['<C-h>'] = false,
    ['<C-x>'] = { 'actions.select', opts = { horizontal = true } },
  },
  win_options = { winbar = '%!v:lua.tuque_oil_winbar()' },
  delete_to_trash = true,
  watch_for_changes = true,
  skip_confirm_for_simple_edits = true,
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
local oil_hints_group = vim.api.nvim_create_augroup('tuque.oil_hints', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = oil_hints_group,
  pattern = 'oil',
  callback = function(args)
    local function draw()
      if not vim.api.nvim_buf_is_valid(args.buf) then return end
      vim.api.nvim_buf_clear_namespace(args.buf, oil_hints_ns, 0, -1)
      local last = vim.api.nvim_buf_line_count(args.buf) - 1
      vim.api.nvim_buf_set_extmark(args.buf, oil_hints_ns, last, 0, { virt_lines = oil_hints })
    end
    draw()
    vim.api.nvim_clear_autocmds({ group = oil_hints_group, buffer = args.buf })
    vim.api.nvim_create_autocmd(
      { 'TextChanged', 'TextChangedI' },
      { group = oil_hints_group, buffer = args.buf, callback = draw }
    )
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
    .. ('%#' .. icon_hl .. '#' .. icon .. '  ')
    .. ('%#Comment#' .. escape(dim))
    .. ('%#Normal#' .. escape(bright))
end
