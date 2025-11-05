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

-- Format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Format on save',
  pattern = '*',
  callback = function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) or vim.bo[args.buf].buftype ~= '' then return end
    if vim.g.disable_autoformat then return end
    vim.lsp.buf.format({
      filter = function(client)
        return vim.tbl_contains({ 'efm', 'terraformls', 'rust-analyzer', 'nil_ls' }, client.name)
      end,
    })
  end,
})

-- Disable diagnostics in the sign column
vim.diagnostic.config({ signs = false })

-- Toggle diagnostics underline
vim.keymap.set('n', '<leader>ud', function()
  vim.diagnostic.config({ underline = not not vim.g.diagnostic_enabled })
  vim.g.diagnostic_enabled = not vim.g.diagnostic_enabled
end, { desc = 'Toggle diagnostic underline', silent = true, noremap = true })

return {
  -- Formatting
  {
    'creativenull/efmls-configs-nvim',
    dependencies = 'neovim/nvim-lspconfig',
    lazy = false,
    keys = {
      {
        '<leader>cf',
        function()
          vim.lsp.buf.format({
            filter = function(client) return client.name == 'efm' end,
          })
        end,
        desc = 'Format',
        mode = { 'n', 'v' },
      },
      {
        '<leader>uf',
        function()
          if vim.g.disable_autoformat == nil then
            vim.g.disable_autoformat = true
          else
            vim.g.disable_autoformat = not vim.g.disable_autoformat
          end
        end,
        desc = 'Toggle format on save',
      },
    },
    config = function()
      local set_formatter = function(lang, formatter)
        vim.lsp.config('efm', {
          settings = { languages = { [lang] = { require('efmls-configs.formatters.' .. formatter) } } },
        })
      end

      set_formatter('python', 'ruff')
      set_formatter('lua', 'stylua')

      -- stylua: ignore
      local languages = {
        'javascript', 'javascriptreact', 'typescript', 'typescriptreact',
        'css', 'scss', 'less', 'html',
        'json', 'jsonc', 'yaml', 'graphql', 'handlebars', 'svelte',
      }
      local has_biome = vim.fn.filereadable(vim.fn.getcwd() .. '/biome.json')
      local web_formatter = has_biome == 1 and 'biome' or 'prettier_d'
      for _, lang in ipairs(languages) do
        set_formatter(lang, web_formatter)
      end

      -- enable efm formatting for all filetypes
      vim.lsp.config('efm', {
        cmd = { 'efm-langserver' },
        filetypes = vim.tbl_keys(vim.lsp.config.efm.settings.languages),
        root_markers = { '.git' },
        init_options = { documentFormatting = true, documentRangeFormatting = true },
      })
      vim.lsp.enable('efm')
    end,
  },

  -- Code actions
  {
    'Chaitanyabsprip/fastaction.nvim',
    keys = {
      {
        '<leader>ca',
        function() require('fastaction').code_action() end,
        desc = 'Code Action',
      },
    },
    --- @module 'fastaction'
    --- @type FastActionConfig
    opts = { dismiss_keys = { 'j', 'k', '<c-c>', 'q', '<Esc>' } },
  },

  -- rename in-place with the LSP and live feedback
  {
    'saecki/live-rename.nvim',
    keys = {
      { 'cr', function() require('live-rename').rename() end, desc = 'Rename' },
      { 'cR', function() require('live-rename').rename({ text = '', insert = true }) end, desc = 'Rename (replace)' },
    },
    opts = { hl = { current = 'LiveRenameCurrent', others = 'LiveRenameOther' } },
  },
  {
    'navarasu/onedark.nvim',
    opts = {
      highlights = {
        LiveRenameCurrent = { fg = '$blue', bg = '$diff_change', fmt = '$none' },
        LiveRenameOther = { fg = '$red', bg = '$diff_delete' },
      },
    },
  },
}
