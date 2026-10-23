local utils = require('tuque.utils')
local map = utils.map

vim.pack.add({ 'https://github.com/supermaven-inc/supermaven-nvim' })

---------------
-- agent
utils.pack_add_dev({ 'https://github.com/saghen/otto.nvim' })
map('n', '=', '<cmd>Otto<cr>', { desc = 'Find session' })
map('n', '<leader>af', '<cmd>Otto<cr>', { desc = 'Find session' })
map('n', '<leader>ap', '<cmd>Otto pi<cr>', { desc = 'New Pi session' })
map('n', '<leader>aP', ':Otto pi ', { silent = false, desc = 'New named Pi session' })
map('n', '<leader>ac', '<cmd>Otto claude<cr>', { desc = 'New Claude session' })
map('n', '<leader>aC', ':Otto claude ', { silent = false, desc = 'New named Claude session' })
map('n', '<leader>ax', '<cmd>Otto codex<cr>', { desc = 'New Codex session' })
map('n', '<leader>aX', ':Otto codex ', { silent = false, desc = 'New named Codex session' })
map('n', '<leader>ar', '<cmd>Otto resume<cr>', { desc = 'Resume session' })
map({ 'n', 'x' }, '<leader>as', ':Otto send<cr>', { desc = 'Send to agent' })

-- buffer history skips otherwise, due to being prompt type
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'otto',
  callback = function(ev) vim.b[ev.buf].buffer_history = true end,
})

-- TODO: schedule to avoid ordering issues
vim.schedule(
  function() require('blink.cmp').lsp.enable({ 'blink_cmp_path', 'blink_cmp_buffer' }, false, { filetype = 'otto' }) end
)

---------------
-- autocomplete
require('supermaven-nvim').setup({
  keymaps = { accept_suggestion = '<M-i>' },
  color = { suggestion_color = vim.g.colors.surface_2 },
  log_level = 'off',
  ignore_filetypes = { 'otto' },
})

-- supermaven copies the whole buffer on every cursor move and every 25ms while polling,
-- so reuse the last copy until buffer change
local util = require('supermaven-nvim.util')
local text_key, text, prefix_key, prefix

util.get_text = function(bufnr)
  local key = bufnr .. ':' .. vim.api.nvim_buf_get_changedtick(bufnr)
  if key ~= text_key then
    text_key = key
    text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
  end
  return text
end
util.get_cursor_prefix = function(bufnr, cursor)
  local key = bufnr .. ':' .. vim.api.nvim_buf_get_changedtick(bufnr) .. ':' .. cursor[1] .. ':' .. cursor[2]
  if key ~= prefix_key then
    prefix = table.concat(vim.api.nvim_buf_get_text(bufnr, 0, 0, cursor[1] - 1, cursor[2], {}), '\n')
    prefix_key = key
  end
  return prefix
end
