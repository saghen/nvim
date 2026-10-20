require('tuque.utils').pack_build('nvim-treesitter', function() vim.cmd('TSUpdate') end)
vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })

-- stylua: ignore
require('nvim-treesitter').install({
  'bash', 'zsh', 'fish',
  'c', 'cpp', 'make', 'cmake',
  'gitcommit', 'gitignore', 'gitattributes', 'git_rebase', 'git_config', 'diff',
  'go', 'gomod', 'terraform',
  'html', 'css', 'typescript', 'tsx', 'javascript', 'jsx',
  'json', 'yaml', 'kdl',
  'luadoc', 'regex',
  'markdown', 'markdown_inline',
  'nix',
  'python',
  'rust', 'just', 'toml',
})

-- start treesitter for any filetype with an installed parser
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('tuque.treesitter', {}),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if lang and vim.treesitter.language.add(lang) then vim.treesitter.start(args.buf, lang) end
  end,
})
