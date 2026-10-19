local map = require('tuque.utils').map

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
      { '<leader>c', group = 'Coding' },
      { '<leader>f', group = 'Files' },
      { '<leader>s', group = 'Search' },
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
  ignore = { buftypes = function(_, buftype) return buftype ~= '' and buftype ~= 'terminal' end },
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
          or term:is_visible() and 'TerminalWinbarVisible'
          or 'Normal'
        table.insert(term_components, { ' ' .. i .. ' ', group = highlight })
      end

      table.insert(term_components, 1, '   ')

      return term_components
    end

    -- File rendering

    local devicons = require('nvim-web-devicons')

    -- Pwd component
    local buf_path = vim.api.nvim_buf_get_name(props.buf)
    local dirname = vim.fn.fnamemodify(buf_path, ':~:.:h')
    local pwd_component = { dirname, group = 'Comment' }

    -- Filename component
    local diagnostic_level = nil
    for _, diagnostic in ipairs(vim.diagnostic.get(props.buf)) do
      diagnostic_level = math.min(diagnostic_level or 999, diagnostic.severity)
    end
    local filename_hl = diagnostic_level == vim.diagnostic.severity.HINT and 'DiagnosticHint'
      or diagnostic_level == vim.diagnostic.severity.INFO and 'DiagnosticInfo'
      or diagnostic_level == vim.diagnostic.severity.WARN and 'DiagnosticWarn'
      or diagnostic_level == vim.diagnostic.severity.ERROR and 'DiagnosticError'
      or 'Normal'
    local filename = vim.fn.fnamemodify(buf_path, ':t')
    if filename == '' then filename = '[No Name]' end
    local filename_component = { filename, group = filename_hl }

    -- Modified icon
    local modified = vim.bo[props.buf].modified
    local modified_component = modified and { ' ● ', group = 'BufferCurrentMod' } or ''

    -- Filetype icon
    local ft_icon, ft_color = devicons.get_icon_color(filename)
    local icon_component = ft_icon and { ' ', ft_icon, ' ', guifg = ft_color } or ''

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
