local map = require('tuque.utils').map

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/Chaitanyabsprip/fastaction.nvim',
  'https://github.com/saecki/live-rename.nvim',
})

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local function map(key, command, opts)
      local mode = opts.mode or 'n'
      opts.mode = nil
      opts.buffer = ev.buf
      vim.keymap.set(mode, key, command, opts)
    end

    map('<leader>cL', '<cmd>LspInfo<cr>', { desc = 'Lsp Info' })
    map(
      'gd',
      function() require('telescope.builtin').lsp_definitions({ reuse_win = true }) end,
      { desc = 'Goto Definition' }
    )
    map('gr', '<cmd>Telescope lsp_references<cr>', { desc = 'References' })
    map('gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })
    map(
      'gi',
      function() require('telescope.builtin').lsp_implementations({ reuse_win = true }) end,
      { desc = 'Goto Implementation' }
    )
    map('gI', 'gi', { noremap = true, desc = 'Go to last insert' })
    map(
      'gy',
      function() require('telescope.builtin').lsp_type_definitions({ reuse_win = true }) end,
      { desc = 'Goto Type Definition' }
    )
    map('K', vim.lsp.buf.hover, { desc = 'Hover' })
    map('gK', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
    map('<c-k>', vim.lsp.buf.signature_help, { mode = 'i', desc = 'Signature Help' })
    map(
      '<leader>cA',
      function()
        vim.lsp.buf.code_action({
          context = {
            only = {
              'source',
            },
            diagnostics = {},
          },
        })
      end,
      { desc = 'Source Action' }
    )
  end,
})

local disable_autoformat_filetypes = {}

-- Format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Format on save',
  pattern = '*',
  callback = function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) or vim.bo[args.buf].buftype ~= '' then return end
    if disable_autoformat_filetypes[vim.bo[args.buf].filetype] then return end
    vim.lsp.buf.format({
      filter = function(client) return vim.tbl_contains({ 'efm', 'rust-analyzer', 'nil_ls' }, client.name) end,
    })
  end,
})

-- Formatting
map({ 'n', 'v' }, '<leader>cf', function()
  vim.lsp.buf.format({ filter = function(client) return client.name == 'efm' end })
end, { desc = 'Format' })
map('n', '<leader>uf', function()
  local filetype = vim.bo.filetype
  disable_autoformat_filetypes[filetype] = not disable_autoformat_filetypes[filetype]
end, { desc = 'Toggle format on save' })
local formatters = {
  ruff = {
    formatCommand = "ruff format --no-cache --stdin-filename '${INPUT}'",
    formatStdin = true,
    rootMarkers = { 'pyproject.toml', 'setup.py', 'requirements.txt', 'ruff.toml' },
  },
  stylua = {
    formatCommand = "stylua --color Never ${--range-start:charStart} ${--range-end:charEnd} --stdin-filepath '${INPUT}' -",
    formatCanRange = true,
    formatStdin = true,
    rootMarkers = { 'stylua.toml', '.stylua.toml' },
  },
  prettier_d = {
    formatCommand = "prettierd '${INPUT}' ${--range-start=charStart} ${--range-end=charEnd} --config-precedence=prefer-file",
    formatCanRange = true,
    formatStdin = true,
    -- stylua: ignore
    rootMarkers = {
      '.prettierrc', '.prettierrc.json', '.prettierrc.js', '.prettierrc.yml', '.prettierrc.yaml', '.prettierrc.json5',
      '.prettierrc.mjs', '.prettierrc.cjs', '.prettierrc.toml', 'prettier.config.js', 'prettier.config.cjs',
      'prettier.config.mjs',
    },
  },
}
local set_formatter = function(lang, formatter)
  vim.lsp.config('efm', { settings = { languages = { [lang] = { formatters[formatter] } } } })
end

set_formatter('python', 'ruff')
set_formatter('lua', 'stylua')

-- stylua: ignore
local web_languages = {
  'javascript', 'javascriptreact', 'typescript', 'typescriptreact',
  'css', 'scss', 'less', 'html',
  'json', 'jsonc', 'yaml', 'graphql', 'handlebars', 'svelte',
}
for _, lang in ipairs(web_languages) do
  set_formatter(lang, 'prettier_d')
end

-- enable efm formatting for all filetypes
vim.lsp.config('efm', {
  cmd = { 'efm-langserver' },
  filetypes = vim.tbl_keys(vim.lsp.config.efm.settings.languages),
  root_markers = { '.git' },
  init_options = { documentFormatting = true, documentRangeFormatting = true },
})
vim.lsp.enable('efm')

-- Code actions
map('n', '<leader>ca', function() require('fastaction').code_action() end, { desc = 'Code Action' })
--- @module 'fastaction'
--- @type FastActionConfig
require('fastaction').setup({ dismiss_keys = { 'j', 'k', '<c-c>', 'q', '<Esc>' } })

-- rename in-place with the LSP and live feedback
map('n', 'cr', function() require('live-rename').rename() end, { desc = 'Rename' })
map(
  'n',
  'cR',
  function() require('live-rename').rename({ text = '', insert = true }) end,
  { desc = 'Rename (replace)' }
)
require('live-rename').setup({ hl = { current = 'LiveRenameCurrent', others = 'LiveRenameOther' } })
