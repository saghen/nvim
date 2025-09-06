return {
  {
    enabled = false,
    'hrsh7th/vim-vsnip',
    init = function() vim.g.vsnip_snippet_dir = vim.fn.stdpath('config') .. '/snippets' end,
  },
  {
    enabled = false,
    'echasnovski/mini.snippets',
    config = function()
      local gen_loader = require('mini.snippets').gen_loader
      require('mini.snippets').setup({
        snippets = {
          -- Load custom file with global snippets first (adjust for Windows)
          gen_loader.from_file('~/code/nvim/tuque/snippets/global.json'),

          -- Load snippets based on current language by reading files from
          -- "snippets/" subdirectories from 'runtimepath' directories.
          gen_loader.from_lang(),
        },
      })
    end,
  },
  {
    enabled = false,
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
    -- version = 'v2.*',
    build = 'make install_jsregexp',
    config = function()
      require('luasnip').config.set_config({
        enable_autosnippets = true,
      })

      local paths = {}
      for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
        if string.match(path, 'friendly.snippets') then table.insert(paths, path) end
      end
      require('luasnip.loaders.from_vscode').lazy_load({ paths = paths })

      local ls = require('luasnip')
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local c = ls.choice_node
      local d = ls.dynamic_node
      local r = ls.restore_node
      local sn = ls.snippet_node
      local fmt = require('luasnip.extras.fmt').fmt
      local fmta = require('luasnip.extras.fmt').fmta
      local postfix = require('luasnip.extras.postfix').postfix
      local matches = require('luasnip.extras.postfix').matches

      -- copy the current selection to the clipboard
      local copy = function()
        local text = vim.fn.getreg('+')
        vim.fn.setreg('+', text)
        return text
      end

      ls.add_snippets('all', {
        -- trigger is `fn`, second argument to snippet-constructor are the nodes to insert into the buffer on expansion.
        s({ trig = ';fn', snippetType = 'autosnippet' }, {
          -- Simple static text.
          t('//Parameters: '),
          -- function, first parameter is the function, second the Placeholders
          -- whose text it gets as input.
          f(copy, 2),
          t({ '', 'function ' }),
          -- Placeholder/Insert.
          i(1),
          t('('),
          -- Placeholder with initial text.
          i(2, 'int foo'),
          -- Linebreak
          t({ ') {', '\t' }),
          -- Last Placeholder, exit Point of the snippet.
          i(0),
          t({ '', '}' }),
        }),

        postfix('fmt', f(function(_, parent) return 'string.format(' .. parent.env.POSTFIX_MATCH .. ')' end, {})),

        -- s('fmt', fmta('("<>"):format(<>)<>', { i(1, 'text'), i(2), i(0) })),

        postfix('/brd', {
          d(1, function(_, parent) return sn(nil, { t('[' .. parent.env.POSTFIX_MATCH .. ']') }) end),
        }),

        s(
          'example2_fmt',
          fmt(
            [[
            if {} then
              {}
            end{} 
            ]],
            {
              i(1, 'not now'),
              i(2, 'when'),
              i(0),
            }
          )
        ),
      })

      local ms = ls.multi_snippet
      ls.add_snippets('all', { ms({ 'a', { trig = 'bb', snippetType = 'autosnippet' } }, { t('b-bb-bbb-bees!') }) })

      -- custom snippets
      ls.add_snippets('markdown', {
        s('figure', {
          t({
            '<figure>',
            '<img src="" loading="lazy" />',
            '<figcaption>',
            '<center>',
          }),
          i(1, 'Lorem'),
          t({
            '</center>',
            '</figcaption>',
            '</figure>',
          }),
        }),
      })
    end,
  },
}
