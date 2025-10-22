return {
  -- prevent neovim from scrolling past the bottom of the buffer
  { 'saghen/filler-begone.nvim' },

  -- forces plugins to use CursorLineSign
  { 'jake-stewart/force-cul.nvim', opts = {} },

  -- shows available keymaps as you type
  {
    enabled = os.getenv('NVIM_DEV') == nil,
    'folke/which-key.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>?',
        function() require('which-key').show({ global = false }) end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
    --- @module 'which-key'
    --- @class wk.Opts
    opts = {
      preset = 'helix',
      delay = 500,
      --- @type wk.Spec
      spec = {
        {
          mode = 'n',
          { '<leader>a', group = 'AI' },
          { '<leader>ag', group = 'AI Prompt' },
          { '<leader>aw', group = 'AI Whisper' },
          { '<leader>b', group = 'Buffers' },
          { '<leader>c', group = 'Coding' },
          { '<leader>d', group = 'Debug' },
          { '<leader>f', group = 'Files' },
          { '<leader>g', group = 'Git' },
          { '<leader>i', group = 'Interfaces' },
          { '<leader>q', group = 'Quit' },
          { '<leader>s', group = 'Search' },
          { '<leader>gsd', group = 'Diff' },
          { '<leader>gs', group = 'Search' },
          { '<leader>go', group = 'Open URL' },
          { '<leader>gy', group = 'Copy URL' },
          { '<leader>u', group = 'Options' },
          { '<leader>w', group = 'Windows' },
          { '<leader>x', group = 'Quickfix' },
        },
      },
      icons = {
        mappings = false,
        breadcrumb = '»', -- symbol used in the command line area that shows your active key combo
        separator = ' ▎ ', -- symbol used between a key and it's label
      },
      show_help = false,
      sort = { 'local', 'order', 'alphanum', 'mod' },
    },
  },
  {
    'navarasu/onedark.nvim',
    opts = {
      highlights = {
        WhichKeyBorder = { bg = '$bg_d', fg = '$bg_d' },
        WhichKeyTitle = { bg = '$bg_d', fg = '$blue' },
        WhichKeySeparator = { fg = '$grey' },
        WhichKey = { fg = '$purple' },
        WhichKeyGroup = { fg = '$grey' },
        WhichKeyDesc = { fg = '$fg' },
      },
    },
  },

  -- UI for commands and search
  {
    enabled = os.getenv('NVIM_DEV') == nil,
    'folke/noice.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    opts = {
      lsp = {
        progress = { enabled = false },
        signature = { enabled = false },
      },
      notify = { enabled = false },
    },
  },

  -- winbar, floating top right
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    opts = {
      ignore = { buftypes = function(_, buftype) return buftype ~= '' and buftype ~= 'terminal' end },
      window = {
        padding = 0,
        margin = { horizontal = 0 },
      },
      render = function(props)
        -- Terminal rendering
        local term_manager = require('tuque.term')
        local term_idx = term_manager.get_current_term_idx(props.win)
        if term_idx ~= nil then
          local terms = term_manager.get_terms()
          local term_components = {}
          for i, term in ipairs(terms) do
            local highlight = i == term_idx and 'TerminalWinbarFocus'
              or term:is_visible() and 'TerminalWinbarVisible'
              or 'Normal'
            table.insert(term_components, { ' ' .. i .. ' ', group = highlight })
          end

          table.insert(term_components, 1, '   ')

          return term_components
        end

        -- Typical rendering

        local devicons = require('nvim-web-devicons')

        -- Filename
        local buf_path = vim.api.nvim_buf_get_name(props.buf)
        local dirname = vim.fn.fnamemodify(buf_path, ':~:.:h')
        local dirname_component = { dirname, group = 'Comment' }

        local filename = vim.fn.fnamemodify(buf_path, ':t')
        if filename == '' then filename = '[No Name]' end
        local diagnostic_level = nil
        for _, diagnostic in ipairs(vim.diagnostic.get(props.buf)) do
          diagnostic_level = math.min(diagnostic_level or 999, diagnostic.severity)
        end
        local filename_hl = diagnostic_level == vim.diagnostic.severity.HINT and 'DiagnosticHint'
          or diagnostic_level == vim.diagnostic.severity.INFO and 'DiagnosticInfo'
          or diagnostic_level == vim.diagnostic.severity.WARN and 'DiagnosticWarn'
          or diagnostic_level == vim.diagnostic.severity.ERROR and 'DiagnosticError'
          or 'Normal'
        local filename_component = { filename, group = filename_hl }

        -- Modified icon
        local modified = vim.bo[props.buf].modified
        local modified_component = modified and { ' ● ', group = 'BufferCurrentMod' } or ''

        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local icon_component = ft_icon and { ' ', ft_icon, ' ', guifg = ft_color } or ''

        return {
          modified_component,
          icon_component,
          ' ',
          filename_component,
          ' ',
          dirname_component,
          ' ',
        }
      end,
    },
  },

  -- partition UI elements
  {
    enabled = false,
    'folke/edgy.nvim',
    event = 'VeryLazy',
    opts = {
      animate = { enabled = false },
      icons = {
        closed = '',
        open = '',
      },
      wo = { winbar = false },
      options = {
        left = { size = 40 },
        right = { size = 80 },
      },
      bottom = {
        'trouble',
        { ft = 'qf', title = 'QuickFix' },
      },
      left = { { ft = 'blink-tree' } },
      right = {
        {
          ft = 'toggleterm',
          -- exclude floating windows
          filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        },
      },
    },
  },

  -- LSP notifications
  {
    'j-hui/fidget.nvim',
    event = 'VeryLazy',
    opts = {
      notification = { window = { normal_hl = 'Normal' } },
      integration = {
        ['nvim-tree'] = { enable = false },
        ['xcodebuild-nvim'] = { enable = false },
      },
    },
  },
}
