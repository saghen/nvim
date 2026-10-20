local map = require('tuque.utils').map

vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/Chaitanyabsprip/fastaction.nvim',
  'https://github.com/saecki/live-rename.nvim',
  { src = 'https://github.com/saecki/crates.nvim', version = 'stable' },
})

local group = vim.api.nvim_create_augroup('tuque.lsp', {})

---------------
-- servers

vim.lsp.config('emmylua_ls', {
  settings = {
    emmylua = {
      runtime = {
        version = 'LuaJIT',
        requirePattern = { 'lua/?.lua', 'lua/?/init.lua', '?/lua/?.lua', '?/lua/?/init.lua' },
      },
      workspace = { ignoreGlobs = { '**/*_spec.lua', '**/test_*.lua', '**/mini.nvim/**' } },
    },
  },
  -- resolve the runtime paths on start, since plugins added after this file aren't on the rtp yet
  before_init = function(_, config)
    config.settings.emmylua.workspace.workspaceRoots = vim.api.nvim_list_runtime_paths()
  end,
})
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      -- https://github.com/napi-rs/napi-rs/issues/944#issuecomment-1013002760
      procMacro = { ignored = { ['napi-derive'] = { 'napi' } } },
      diagnostics = { disabled = { 'proc-macro-disabled' } },
      -- build in sub directory to prevent locking
      cargo = { targetDir = true },
    },
  },
})

vim.lsp.enable({ 'efm', 'emmylua_ls', 'gopls', 'nil_ls', 'rust_analyzer', 'tsc', 'ty' })

-- cargo.toml lsp
require('crates').setup({
  lsp = { enabled = true, actions = true, completion = true, hover = true },
  completion = { crates = { enabled = true } },
})

---------------
-- keymaps

-- drop the default gr* mappings, so that gr (references) doesn't wait for the next key
for _, lhs in ipairs({ 'grn', 'grr', 'gra', 'gri', 'grt', 'grx' }) do
  pcall(vim.keymap.del, 'n', lhs)
end
pcall(vim.keymap.del, 'x', 'gra')

local fastaction = require('fastaction')
fastaction.setup({ dismiss_keys = { 'j', 'k', '<c-c>', 'q', '<Esc>' } })

-- rename in-place with the LSP and live feedback
local live_rename = require('live-rename')
live_rename.setup({ hl = { current = 'LiveRenameCurrent', others = 'LiveRenameOther' } })

-- map the following keys after the lsp attaches to the buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(ev)
    local function bmap(mode, lhs, rhs, opts) map(mode, lhs, rhs, vim.tbl_extend('force', opts, { buffer = ev.buf })) end

    bmap('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
    bmap('n', 'gr', vim.lsp.buf.references, { desc = 'References' })
    bmap('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })
    bmap('n', 'gi', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
    bmap('n', 'gI', 'gi', { desc = 'Go to last insert' })
    bmap('n', 'gy', vim.lsp.buf.type_definition, { desc = 'Goto Type Definition' })
    bmap('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })
    -- visual mode passes the selection as the range
    bmap({ 'n', 'x' }, 'ga', function() fastaction.code_action() end, { desc = 'Code Action' })
    -- normal mode only, so that cgn/cgN keep working
    bmap('n', 'gn', function() live_rename.rename() end, { desc = 'Rename' })
    bmap('n', 'gN', function() live_rename.rename({ text = '', insert = true }) end, { desc = 'Rename (replace)' })
  end,
})

-- disable diagnostics in the sign column
vim.diagnostic.config({ signs = false })

-- toggle diagnostics underline
map(
  'n',
  '<leader>ud',
  function() vim.diagnostic.config({ underline = not vim.diagnostic.config().underline }) end,
  { desc = 'Toggle diagnostic underline' }
)

---------------
-- formatting

local function format_filter(client) return vim.list_contains({ 'efm', 'rust_analyzer' }, client.name) end

local disable_autoformat_filetypes = {}
map('n', '<leader>uf', function()
  local filetype = vim.bo.filetype
  disable_autoformat_filetypes[filetype] = not disable_autoformat_filetypes[filetype]
end, { desc = 'Toggle format on save' })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  desc = 'Format on save',
  callback = function(args)
    if vim.bo[args.buf].buftype ~= '' then return end
    if disable_autoformat_filetypes[vim.bo[args.buf].filetype] then return end
    -- otherwise format() warns on every save of a filetype without a formatter
    local clients = vim.lsp.get_clients({ bufnr = args.buf, method = 'textDocument/formatting' })
    if #vim.tbl_filter(format_filter, clients) == 0 then return end
    vim.lsp.buf.format({ bufnr = args.buf, filter = format_filter })
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
  filetypes = vim.tbl_keys(vim.lsp.config.efm.settings.languages),
  init_options = { documentFormatting = true, documentRangeFormatting = true },
})
