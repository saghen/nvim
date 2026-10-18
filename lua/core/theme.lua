vim.pack.add({ 'https://github.com/navarasu/onedark.nvim' })

require('onedark').setup({
  transparent = false,
  colors = {
    black = vim.g.colors.crust,
    bg0 = vim.g.colors.base,
    bg1 = vim.g.colors.core,
    bg2 = vim.g.colors.surface_0,
    bg3 = vim.g.colors.surface_1,
    bg_d = vim.g.colors.mantle,
    grey = vim.g.surface_2,
    -- todo: is this one right?
    light_grey = vim.g.colors.overlay_2,

    -- todo: change these
    dark_bg_blue = '#16334B',
    dark_bg_green = '#2b3425',
    dark_bg_red = '#301c1e',
    dark_bg_yellow = '#685127',
    dark_bg_purple = '#42204C',

    -- blue = vim.g.colors.blue,
    -- cyan = vim.g.colors.cyan,
    -- green = vim.g.colors.green,
    -- orange = vim.g.colors.peach,
    -- purple = vim.g.colors.muave,
    -- red = vim.g.colors.red,
    -- yellow = vim.g.colors.yellow,
  },
  highlights = {
    Blue = { fg = '$blue' },
    Cyan = { fg = '$cyan' },
    Green = { fg = '$green' },
    Orange = { fg = '$orange' },
    Purple = { fg = '$purple' },
    Red = { fg = '$red' },
    Yellow = { fg = '$yellow' },

    Primary = { fg = '$blue' },
    ['@comment'] = { fg = '$blue' },
    ['@lsp.type.comment'] = { fg = '$blue' },

    ['@operator'] = { fg = '$cyan' },
    ['@lsp.type.variable'] = { fg = '$yellow' },
    ['@lsp.type.property'] = { fg = '$red' },
    ['@lsp.type.generic'] = { fg = '$red' },

    NormalFloat = { bg = '$bg_d' },
    FloatBorder = { bg = '$bg_d' },
    PMenuSel = { bg = '$blue', fg = '$bg1' },
    WinSeparator = { fg = '$bg2', bg = '$bg_d' },
    WinBar = { bg = '$bg0' },
    WinBarNC = { bg = '$bg0' },
    StatusLine = { bg = '$bg0', fg = '$bg0' },
    StatusLineNC = { bg = '$bg0', fg = '$bg0' },

    BufferCurrentMod = { fg = '$yellow', fmt = 'bold' },

    RainbowOrange = { fg = '$orange' },
    RainbowPurple = { fg = '$purple' },
    RainbowBlue = { fg = '$blue' },
    RainbowOrangeUnderline = { sp = '$orange', fmt = 'underline' },
    RainbowPurpleUnderline = { sp = '$purple', fmt = 'underline' },
    RainbowBlueUnderline = { sp = '$blue', fmt = 'underline' },

    MatchParen = { fg = '$yellow', bg = 'transparent' },

    InclineNormal = { bg = '$bg1' },
    InclineNormalNC = { bg = '$bg1' },

    BlinkCmpGhostText = { fg = '$grey' },
    BlinkCmpMenu = { bg = '$bg1' },
    BlinkCmpMenuSelection = { bg = '$bg3' },
    BlinkCmpLabelMatch = { fmt = 'bold', fg = 'transparent' },
    BlinkCmpLabelDetail = { fg = '$light_grey' },
    BlinkCmpLabelDescription = { fg = '$light_grey' },
    BlinkCmpDoc = { bg = '$bg_d' },
    BlinkCmpDocBorder = { bg = '$bg_d' },
    BlinkCmpScrollBarThumb = { bg = '$grey' },
    BlinkCmpScrollBarGutter = { bg = '$bg1' },

    BlinkIndent = { fg = '$bg1' },
    BlinkPairsUnmatched = { fg = '$red' },

    CursorLine = { bg = '$bg1' },
    CursorLineNr = { bg = '$bg1' },
    CursorLineSign = { bg = '$bg1' },
    ModeNormal = { fg = '$green', bg = '$bg1' },
    ModeInsert = { fg = '$blue', bg = '$bg1' },
    ModeVisual = { fg = '$purple', bg = '$bg1' },
    ModeCommand = { fg = '$red', bg = '$bg1' },
    ModeSelect = { fg = '$purple', bg = '$bg1' },
    ModeReplace = { fg = '$red', bg = '$bg1' },
    ModeTerminal = { fg = '$yellow', bg = '$bg1' },

    TelescopePathSeparator = { fg = '$light_grey' },

    TelescopePreviewBorder = { fg = '$grey' },
    TelescopePromptBorder = { fg = '$grey' },
    TelescopeResultsBorder = { fg = '$grey' },

    TelescopePreviewTitle = { fg = '$blue' },
    TelescopePromptTitle = { fg = '$blue' },
    TelescopeResultsTitle = { fg = '$blue' },

    TerminalWinbarFocus = { bg = '$blue', fg = '$black' },
    TerminalAgentWinbarFocus = { bg = '$green', fg = '$black' },

    LiveRenameCurrent = { fg = '$blue', bg = '$diff_change', fmt = '$none' },
    LiveRenameOther = { fg = '$red', bg = '$diff_delete' },

    WhichKeyBorder = { bg = '$bg_d', fg = '$bg_d' },
    WhichKeyTitle = { bg = '$bg_d', fg = '$blue' },
    WhichKeySeparator = { fg = '$grey' },
    WhichKey = { fg = '$purple' },
    WhichKeyGroup = { fg = '$grey' },
    WhichKeyDesc = { fg = '$fg' },
  },
})
require('onedark').load()

vim.api.nvim_set_hl(0, 'BlinkIndentOrange', { link = 'RainbowOrange' })
vim.api.nvim_set_hl(0, 'BlinkIndentViolet', { link = 'RainbowPurple' })
vim.api.nvim_set_hl(0, 'BlinkIndentBlue', { link = 'RainbowBlue' })
vim.api.nvim_set_hl(0, 'BlinkPairsOrange', { link = 'RainbowOrange' })
vim.api.nvim_set_hl(0, 'BlinkPairsPurple', { link = 'RainbowPurple' })
vim.api.nvim_set_hl(0, 'BlinkPairsBlue', { link = 'RainbowBlue' })
