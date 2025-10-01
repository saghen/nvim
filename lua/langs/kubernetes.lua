vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { '*/templates/*.yaml', '*/templates/*.tpl', '*.gotmpl', 'helmfile*.yaml' },
  callback = function() vim.opt_local.filetype = 'helm' end,
})

local write_file = function(path, text)
  local fd, _, open_err = vim.uv.fs_open(path, 'w', 438)
  if open_err or fd == nil then
    vim.notify(open_err or 'Failed to create temporary file', vim.log.levels.ERROR)
    return
  end
  local _, _, write_err = vim.uv.fs_write(fd, text)
  if write_err then
    vim.notify(write_err, vim.log.levels.ERROR)
    return
  end
  vim.uv.fs_close(fd)
end

local map = require('tuque.utils').map
map('v', '<leader>ka', function()
  vim.cmd.normal({ '"zy', bang = true })
  local text = vim.fn.getreg('z')
  write_file('/tmp/apply.yaml', text)

  local success = pcall(require('tuque.term').focus_last)
  if not success then require('tuque.term').cycle() end

  vim.schedule(function()
    vim.cmd('startinsert')
    -- write the text to the terminal
    vim.api.nvim_paste('bat --decorations=never --paging=never /tmp/apply.yaml', true, 1)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
    vim.api.nvim_feedkeys('kubectl apply -f /tmp/apply.yaml', 'n', false)
  end)
end, { desc = 'Apply selected yaml' })
map('v', '<leader>kd', function()
  vim.cmd.normal({ '"zy', bang = true })
  local text = vim.fn.getreg('z')
  write_file('/tmp/delete.yaml', text)

  local success = pcall(require('tuque.term').focus_last)
  if not success then require('tuque.term').cycle() end

  vim.schedule(function()
    vim.cmd('startinsert')
    -- write the text to the terminal
    vim.api.nvim_paste('bat --decorations=never --paging=never /tmp/delete.yaml', true, 1)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
    vim.api.nvim_feedkeys('kubectl delete -f /tmp/apply.yaml', 'n', false)
  end)
end, { desc = 'Delete selected yaml' })

return {
  -- UI
  {
    'ramilito/kubectl.nvim',
    version = '2.*',
    dependencies = 'saghen/blink.download',
    keys = {
      {
        '<leader>ik',
        function() require('kubectl').toggle() end,
        desc = 'Kubectl',
      },
    },
    --- @module "kubectl"
    --- @class KubectlOptions
    opts = {},
  },
  {
    'navarasu/onedark.nvim',
    opts = {
      highlights = {
        KubectlHeader = { fg = '$fg', fmt = 'bold' },
        KubectlSuccess = { fg = '$green' },
        KubectlPending = { fg = '$yellow' },
        KubectlWarning = { fg = '$yellow' },
      },
    },
  },

  -- treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'yaml' } },
  },
  -- LSP and schemas for autocompletion
  { 'towolf/vim-helm', ft = 'helm' },
}
