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

return {}
