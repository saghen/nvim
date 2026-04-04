vim.treesitter.start()

vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ['rust-analyzer'] = {
        -- https://github.com/napi-rs/napi-rs/issues/944#issuecomment-1013002760
        procMacro = { ignored = { ['napi-derive'] = { 'napi' } } },
        -- build in sub directory to prevent locking
        cargo = { targetDir = true },
      },
    },
  },
}

local map = function(desc, key, command)
  vim.keymap.set('n', key, command, { silent = true, buffer = vim.api.nvim_get_current_buf(), desc = desc })
end

-- map('Hover', 'K', function() vim.cmd.RustLsp({ 'hover', 'actions' }) end)
map('Rebuild Proc Macros', '<leader>cr', function() vim.cmd.RustLsp('rebuildProcMacros') end)
map('Open Docs.rs', '<leader>cD', function() vim.cmd.RustLsp({ 'openDocs' }) end)
