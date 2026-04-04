-- define icons for the diagnostics in the sign column
-- even though we have them disabled
vim.fn.sign_define('DiagnosticSignError', { texthl = 'DiagnosticSignError', text = '' })
vim.fn.sign_define('DiagnosticSignWarn', { texthl = 'DiagnosticSignWarn', text = '' })
vim.fn.sign_define('DiagnosticSignHint', { texthl = 'DiagnosticSignHint', text = '' })
vim.fn.sign_define('DiagnosticSignInfo', { texthl = 'DiagnosticSignInfo', text = '' })

-- Disable diagnostics in the sign column
vim.diagnostic.config({ signs = false })

-- Toggle diagnostics underline
vim.keymap.set('n', '<leader>ud', function()
  vim.diagnostic.config({ underline = not not vim.g.diagnostic_enabled })
  vim.g.diagnostic_enabled = not vim.g.diagnostic_enabled
end, { desc = 'Toggle diagnostic underline', silent = true, noremap = true })

return {
  -- UI for viewing all diagnostics
  {
    'folke/trouble.nvim',
    dependencies = { 'rachartier/tiny-devicons-auto-colors.nvim' },
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics open<cr>',
        desc = 'Diagnostics',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics open filter.buf=0<cr>',
        desc = 'Buffer Diagnostics',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols open focus=false<cr>',
        desc = 'Symbols',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp open focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ...',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist open<cr>',
        desc = 'Location List',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist open<cr>',
        desc = 'Quickfix List',
      },
    },
    --- @module 'trouble'
    --- @type trouble.Config
    opts = {
      focus = true,
      throttle = {
        preview = { debounce = false },
      },
      action_keys = {
        previous = { 'k', '<Up>' },
        next = { 'j', '<Down>' },
      },
    },
  },
}
