local map = require('tuque.utils').map

vim.api.nvim_create_autocmd('InsertLeave', { callback = vim.snippet.stop })

-- autocomplete
if os.getenv('NVIM_DEV') == nil then
  vim.pack.add({ 'https://github.com/supermaven-inc/supermaven-nvim' })
  vim.api.nvim_create_autocmd('InsertEnter', {
    once = true,
    callback = function()
      require('supermaven-nvim').setup({
        keymaps = { accept_suggestion = '<M-i>' },
        -- TODO: use onedark.nvim
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
    end,
  })
end

vim.pack.add({ 'https://github.com/theprimeagen/99' })
map('v', '<leader>9v', function() require('99').visual() end, { desc = 'AI Agent (Visual)' })
map('n', '<leader>9x', function() require('99').stop_all_requests() end, { desc = 'Cancel all AI Agents' })
map('n', '<leader>9s', function() require('99').search() end, { desc = 'AI Agent (Search)' })
local _99 = require('99')
_99.setup({
  provider = _99.Providers.ClaudeCodeProvider,
  model = 'opus',
})

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/olimorris/codecompanion.nvim',
})
-- map({ 'n', 'v' }, '<C-a>', '<cmd>CodeCompanionActions<cr>', { desc = 'Add to AI Chat' })
map('v', 'ga', '<cmd>CodeCompanionChat Add<cr>', { desc = 'Add to AI Chat' })
map('n', '<leader>ac', '<cmd>CodeCompanionChat<cr>', { desc = 'New Chat' })
vim.cmd([[cab cc CodeCompanion]])
require('codecompanion').setup({
  interactions = {
    chat = { adapter = { name = 'openrouter', model = 'typesafe/jev-router' } },
    inline = { adapter = { name = 'openrouter', model = 'typesafe/jev-router' } },
    cmd = { adapter = { name = 'openrouter', model = 'typesafe/jev-router' } },
  },
  adapters = {
    http = {
      anthropic = function()
        return require('codecompanion.adapters').extend('anthropic', { env = { api_key = vim.g.ANTHROPIC_API_KEY } })
      end,
      openrouter = function()
        return require('codecompanion.adapters').extend('openrouter', {
          env = { api_key = vim.g.OPENROUTER_API_KEY },
        })
      end,
    },
    acp = {
      claude_code = function()
        return require('codecompanion.adapters').extend('claude_code', {
          env = { CLAUDE_CODE_OAUTH_TOKEN = function() return os.getenv('CLAUDE_CODE_OAUTH_TOKEN') end },
        })
      end,
    },
  },
  display = { chat = { intro_message = '', window = { layout = 'buffer' } } },
})
