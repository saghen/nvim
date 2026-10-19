local map = require('tuque.utils').map

local group = vim.api.nvim_create_augroup('tuque.lsp', {})

-- map the following keys after the lsp attaches to the buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(ev)
    local function map(key, command, opts)
      local mode = opts.mode or 'n'
      opts.mode = nil
      opts.buffer = ev.buf
      vim.keymap.set(mode, key, command, opts)
    end

    map('<leader>cL', '<cmd>LspInfo<cr>', { desc = 'Lsp Info' })
    map('gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
    map('gr', vim.lsp.buf.references, { desc = 'References' })
    map('gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })
    map('gi', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
    map('gI', 'gi', { noremap = true, desc = 'Go to last insert' })
    map('gy', vim.lsp.buf.type_definition, { desc = 'Goto Type Definition' })
    map('K', vim.lsp.buf.hover, { desc = 'Hover' })
    map('gK', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
    map('<c-k>', vim.lsp.buf.signature_help, { mode = 'i', desc = 'Signature Help' })
    map('<leader>cA', vim.lsp.buf.code_action, { desc = 'Code Action' })
  end,
})

-- code actions
local fastaction = require('fastaction')
map('n', '<leader>ca', function() fastaction.code_action() end, { desc = 'Code Action' })
fastaction.setup({ dismiss_keys = { 'j', 'k', '<c-c>', 'q', '<Esc>' } })

-- rename in-place with the LSP and live feedback
local live_rename = require('live-rename')
map('n', 'cr', function() live_rename.rename() end, { desc = 'Rename' })
map('n', 'cR', function() live_rename.rename({ text = '', insert = true }) end, { desc = 'Rename (replace)' })
live_rename.setup({ hl = { current = 'LiveRenameCurrent', others = 'LiveRenameOther' } })

-- disable diagnostics in the sign column
vim.diagnostic.config({ signs = false })

-- toggle diagnostics underline
vim.keymap.set(
  'n',
  '<leader>ud',
  function() vim.diagnostic.config({ underline = not vim.diagnostic.config().underline }) end,
  { desc = 'Toggle diagnostic underline', silent = true, noremap = true }
)

---------------
-- formatting

map({ 'n', 'v' }, '<leader>cf', function()
  vim.lsp.buf.format({
    filter = function(client) return vim.tbl_contains({ 'efm', 'rust-analyzer', 'nil_ls' }, client.name) end,
  })
end, { desc = 'Format' })

local disable_autoformat_filetypes = {}
map('n', '<leader>uf', function()
  local filetype = vim.bo.filetype
  disable_autoformat_filetypes[filetype] = not disable_autoformat_filetypes[filetype]
end, { desc = 'Toggle format on save' })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
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

-- get more from: https://github.com/creativenull/efmls-configs-nvim
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

---------------
-- servers

vim.lsp.config('emmylua_ls', {
  settings = {
    emmylua = {
      runtime = {
        version = 'LuaJIT',
        requirePattern = { 'lua/?.lua', 'lua/?/init.lua', '?/lua/?.lua', '?/lua/?/init.lua' },
      },
      workspace = {
        ignoreGlobs = { '**/*_spec.lua', '**/test_*.lua', '**/mini.nvim/**' },
      },
    },
  },
  -- resolve the runtime paths on start, since plugins added after this file aren't on the rtp yet
  before_init = function(_, config)
    config.settings.emmylua.workspace.workspaceRoots = vim.api.nvim_list_runtime_paths()
  end,
})
vim.lsp.config('nil_ls', { settings = { ['nil'] = { formatting = { command = { 'nixfmt' } } } } })

-- rust-analyzer is started by rustaceanvim
vim.lsp.enable({ 'efm', 'emmylua_ls', 'gopls', 'nil_ls', 'tsc', 'ty' })
