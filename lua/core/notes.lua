vim.api.nvim_create_autocmd('User', {
  pattern = 'ObsidianNoteEnter',
  callback = function(ev)
    vim.keymap.del('n', '<CR>', { buffer = ev.buf })
    vim.keymap.set('n', '<leader><CR>', require('obsidian.api').smart_action, { buffer = ev.buf })
  end,
})

return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  cmd = 'Obsidian',
  ft = 'markdown',
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    ui = { enable = false },
    workspaces = { { name = 'notes', path = '~/notes' } },
  },
}
