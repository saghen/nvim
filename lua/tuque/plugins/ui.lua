local map = require('tuque.utils').map

vim.pack.add({
  -- prevents scrolling past the end of the buffer
  'https://github.com/saghen/filler-begone.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/folke/which-key.nvim',
  -- TODO: revert on merge https://github.com/b0o/incline.nvim/pull/96
  { src = 'https://github.com/noib3/incline.nvim', version = 'fix/retrack-windows-on-buffer-change' },
})

-- LSP notifications
require('fidget').setup({ notification = { window = { normal_hl = 'Normal' } } })

-- shows available keymaps as you type
map(
  'n',
  '<leader>?',
  function() require('which-key').show({ global = false }) end,
  { desc = 'Buffer Local Keymaps (which-key)' }
)
require('which-key').setup({
  preset = 'helix',
  delay = 500,
  --- @type wk.Spec
  spec = {
    {
      mode = 'n',
      { '<leader>a', group = 'Agent' },
      { '<leader>b', group = 'Buffers' },
      { '<leader>c', group = 'Copy' },
      { '<leader>f', group = 'Find' },
      { '<leader>u', group = 'Options' },
      { '<leader>w', group = 'Windows' },
    },
  },
  icons = { mappings = false, breadcrumb = '»', separator = ' ▎ ' },
  show_help = false,
  sort = { 'local', 'order', 'alphanum', 'mod' },
})

-- winbar
require('incline').setup({
  hide = { cursorline = 'smart' },
  -- only files and terminals, so not the unnamed buffer of the intro screen either
  ignore = {
    buftypes = function(buf, buftype)
      return (buftype ~= '' and buftype ~= 'terminal') or vim.api.nvim_buf_get_name(buf) == ''
    end,
  },
  window = { padding = 0, margin = { horizontal = 0 } },
  render = function(props)
    -- Terminal rendering
    local term_manager = require('tuque.term')
    local active_term = term_manager.get_current_term(props.win)
    local active_term_idx = active_term and term_manager.get_current_term_idx(active_term.type, props.win)
    if active_term_idx ~= nil and active_term ~= nil then
      local terms = term_manager.get_terms(active_term.type)
      local term_components = {}
      for i, term in ipairs(terms) do
        local highlight = i == active_term_idx
            and (term.type == 'agent' and 'TerminalAgentWinbarFocus' or 'TerminalWinbarFocus')
          or 'Normal'
        table.insert(term_components, { ' ' .. i .. ' ', group = highlight })
      end

      table.insert(term_components, 1, '   ')

      return term_components
    end

    -- File rendering

    -- Pwd component
    local buf_path = vim.api.nvim_buf_get_name(props.buf)
    local dirname = vim.fn.fnamemodify(buf_path, ':~:.:h')
    local pwd_component = { dirname, group = 'Comment' }

    -- Filename component
    -- colored by the highest severity diagnostic
    local severity = math.min(math.huge, unpack(vim.tbl_keys(vim.diagnostic.count(props.buf))))
    local filename_hl = ({ 'DiagnosticError', 'DiagnosticWarn', 'DiagnosticInfo', 'DiagnosticHint' })[severity]
      or 'Normal'
    local filename = vim.fn.fnamemodify(buf_path, ':t')
    local filename_component = { filename, group = filename_hl }

    -- Modified icon
    local modified = vim.bo[props.buf].modified
    local modified_component = modified and { ' ● ', group = 'BufferCurrentMod' } or ''

    -- Filetype icon
    local icon, icon_hl = MiniIcons.get('file', filename)
    local icon_component = { ' ', icon, ' ', group = icon_hl }

    return {
      modified_component,
      icon_component,
      ' ',
      filename_component,
      ' ',
      pwd_component,
      ' ',
    }
  end,
})
