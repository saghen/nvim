return {
  { 'nvim-mini/mini.ai', opts = {} },

  {
    'Wansmer/treesj',
    keys = { { 'gm', '<cmd>TSJToggle<cr>', desc = 'Toggle Block' } },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { use_default_keymap = false, max_join_length = 1000 },
  },

  -- todo: use `vim.b.minicursorword_disable` to disable in tree
  { 'nvim-mini/mini.cursorword', version = false, opts = { delay = 400 } },
  {
    'nvim-mini/mini.surround',
    version = '*',
    keys = {
      { 'sa', desc = 'Add surrounding', mode = { 'n', 'v' } },
      { 'sd', desc = 'Delete surrounding' },
      { 'sf', desc = 'Find right surrounding' },
      { 'sF', desc = 'Find left surrounding' },
      { 'sh', desc = 'Highlight surrounding' },
      { 'sr', desc = 'Replace surrounding' },
    },
    opts = {
      -- Number of lines within which surrounding is searched
      n_lines = 50,
      mappings = {
        add = 'sa', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sr', -- Replace surrounding
      },
    },
  },
  {
    'nvim-mini/mini.bufremove',
    keys = {
      {
        '<leader>bd',
        function()
          local bd = require('mini.bufremove').delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(('Save changes to %q?'):format(vim.fn.bufname()), '&Yes\n&No\n&Cancel')
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = 'Delete Buffer',
      },
      {
        '<leader>bD',
        function() require('mini.bufremove').delete(0, true) end,
        desc = 'Delete Buffer (Force)',
      },
    },
  },

  {
    'xzbdmw/clasp.nvim',
    keys = {
      -- Equivalent of h and l but on the left split keyboard with colemak-dh
      {
        '<C-t>',
        function() require('clasp').wrap('next') end,
        mode = { 'i', 'n' },
        desc = 'Wrap next treesitter node with paranthesis',
      },
      {
        '<C-a>',
        function() require('clasp').wrap('prev') end,
        mode = { 'i', 'n' },
        desc = 'Wrap previous treesitter node with paranthesis',
      },
    },
    opts = {},
  },
}
