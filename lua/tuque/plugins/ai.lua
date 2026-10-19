local map = require('tuque.utils').map

-- agent
local _99 = require('99')
map('v', '<leader>av', function() _99.visual() end, { desc = 'AI Agent (Visual)' })
map('n', '<leader>ax', function() _99.stop_all_requests() end, { desc = 'Cancel all AI Agents' })
map('n', '<leader>as', function() _99.search() end, { desc = 'AI Agent (Search)' })
_99.setup({ provider = _99.Providers.ClaudeCodeProvider, model = 'opus' })

-- autocomplete
require('supermaven-nvim').setup({
  keymaps = { accept_suggestion = '<M-i>' },
  color = { suggestion_color = '#585b70' },
  log_level = 'off',
})

-- supermaven copies the whole buffer into a string on every cursor move (normal mode too) and
-- every 25ms while polling for a completion, so reuse the last copy until the buffer changes
local util = require('supermaven-nvim.util')
local get_text, get_cursor_prefix = util.get_text, util.get_cursor_prefix
local text_key, text, prefix_key, prefix
util.get_text = function(bufnr)
  local key = bufnr .. ':' .. vim.api.nvim_buf_get_changedtick(bufnr)
  if key ~= text_key then
    text_key, text = key, get_text(bufnr)
  end
  return text
end
util.get_cursor_prefix = function(bufnr, cursor)
  local key = bufnr .. ':' .. vim.api.nvim_buf_get_changedtick(bufnr) .. ':' .. cursor[1] .. ':' .. cursor[2]
  if key ~= prefix_key then
    prefix_key, prefix = key, get_cursor_prefix(bufnr, cursor)
  end
  return prefix
end
