-- onedark's "dark" accents on top of the backgrounds from vim.g.colors
local colors = vim.g.colors
local c = {
  black = colors.crust,
  bg_d = colors.mantle,
  bg0 = colors.base,
  bg1 = colors.core,
  bg2 = colors.surface_0,
  bg3 = colors.surface_1,
  grey = colors.surface_2,
  light_grey = colors.overlay_2,
  fg = '#bec5d2',

  red = '#e86671',
  orange = '#d19a66',
  yellow = '#e5c07b',
  green = '#98c379',
  cyan = '#56b6c2',
  blue = '#61afef',
  purple = '#c678dd',

  bg_blue = '#73b8f1',
  bg_yellow = '#ebd09c',
  dark_red = '#993939',
  dark_yellow = '#93691d',
  dark_cyan = '#2b6f77',
  dark_purple = '#8a3fa0',

  diff_add = '#31392b',
  diff_change = '#1c3448',
  diff_delete = '#382b2c',
  diff_text = '#2c5372',
}

--- blends the color into the background, where 0 is the background and 1 is the color
local function darken(color, alpha)
  local function mix(i)
    local fg, bg = tonumber(color:sub(i, i + 1), 16), tonumber(c.bg0:sub(i, i + 1), 16)
    return math.floor(alpha * fg + (1 - alpha) * bg + 0.5)
  end
  return ('#%02x%02x%02x'):format(mix(2), mix(4), mix(6))
end

-- strings link to another group
local hl = {
  -- editor
  Normal = { fg = c.fg, bg = c.bg0 },
  NormalFloat = { fg = c.fg, bg = c.bg_d },
  FloatBorder = { fg = c.grey, bg = c.bg_d },
  Terminal = 'Normal',
  EndOfBuffer = { fg = c.bg0, bg = c.bg0 },
  SignColumn = { fg = c.fg, bg = c.bg0 },
  FoldColumn = { fg = c.fg, bg = c.bg1 },
  Folded = { fg = c.fg, bg = c.bg1 },
  Cursor = { reverse = true },
  CursorIM = 'Cursor',
  lCursor = 'Cursor',
  CursorColumn = { bg = c.bg1 },
  CursorLine = { bg = c.bg1 },
  CursorLineNr = { fg = c.fg, bg = c.bg1 },
  CursorLineSign = { bg = c.bg1 },
  ColorColumn = { bg = c.bg1 },
  LineNr = { fg = c.grey },
  Conceal = { fg = c.grey, bg = c.bg1 },
  NonText = { fg = c.grey },
  Whitespace = { fg = c.grey },
  SpecialKey = { fg = c.grey },
  Visual = { bg = c.bg3 },
  VisualNOS = { bg = c.bg2, underline = true },
  MatchParen = { fg = c.yellow },
  WinSeparator = { fg = c.bg2, bg = c.bg_d },
  WinBar = { fg = c.fg, bg = c.bg0 },
  WinBarNC = { fg = c.grey, bg = c.bg0 },
  StatusLine = { fg = c.bg0, bg = c.bg0 },
  StatusLineNC = { fg = c.bg0, bg = c.bg0 },
  StatusLineTerm = { fg = c.fg, bg = c.bg2 },
  StatusLineTermNC = { fg = c.grey, bg = c.bg1 },
  TabLine = { fg = c.fg, bg = c.bg1 },
  TabLineFill = { fg = c.grey, bg = c.bg1 },
  TabLineSel = { fg = c.bg0, bg = c.fg },
  Pmenu = { fg = c.fg, bg = c.bg1 },
  PmenuSel = { fg = c.bg1, bg = c.blue },
  PmenuSbar = { bg = c.bg1 },
  PmenuThumb = { bg = c.grey },
  WildMenu = { fg = c.bg0, bg = c.blue },
  QuickFixLine = { bg = darken(c.blue, 0.15) },
  QuickFixFilename = { fg = colors.subtext_0 },
  QuickFixLineNr = 'QuickFixFilename',
  QuickFixBorder = { fg = c.grey },
  Directory = { fg = c.blue },
  Title = { fg = c.cyan },
  Question = { fg = c.yellow },
  MoreMsg = { fg = c.blue, bold = true },
  ErrorMsg = { fg = c.red, bold = true },
  WarningMsg = { fg = c.yellow, bold = true },
  Search = { fg = c.bg0, bg = c.bg_yellow },
  IncSearch = { fg = c.bg0, bg = c.orange },
  CurSearch = 'IncSearch',
  Substitute = { fg = c.bg0, bg = c.green },
  SpellBad = { undercurl = true, sp = c.red },
  SpellCap = { undercurl = true, sp = c.yellow },
  SpellLocal = { undercurl = true, sp = c.blue },
  SpellRare = { undercurl = true, sp = c.purple },
  Debug = { fg = c.yellow },
  debugPC = { fg = c.bg0, bg = c.green },
  debugBreakpoint = { fg = c.bg0, bg = c.red },

  -- diffs
  Added = { fg = c.green },
  Changed = { fg = c.blue },
  Removed = { fg = c.red },
  DiffAdd = { bg = c.diff_add },
  DiffChange = { bg = c.diff_change },
  DiffDelete = { bg = c.diff_delete },
  DiffText = { bg = c.diff_text },
  DiffAdded = 'Added',
  DiffChanged = 'Changed',
  DiffRemoved = 'Removed',
  DiffDeleted = 'Removed',
  DiffFile = { fg = c.cyan },
  DiffIndexLine = { fg = c.grey },

  -- syntax
  Comment = { fg = c.grey, italic = true },
  SpecialComment = 'Comment',
  Todo = { fg = c.red, italic = true },
  String = { fg = c.green },
  Character = { fg = c.orange },
  Number = { fg = c.orange },
  Float = { fg = c.orange },
  Boolean = { fg = c.orange },
  Constant = { fg = c.cyan },
  Identifier = { fg = c.red },
  Function = { fg = c.blue },
  Type = { fg = c.yellow },
  Structure = { fg = c.yellow },
  StorageClass = { fg = c.yellow },
  Typedef = { fg = c.yellow },
  Statement = { fg = c.purple },
  Keyword = { fg = c.purple },
  Conditional = { fg = c.purple },
  Repeat = { fg = c.purple },
  Label = { fg = c.purple },
  Exception = { fg = c.purple },
  Operator = { fg = c.purple },
  PreProc = { fg = c.purple },
  PreCondit = { fg = c.purple },
  Include = { fg = c.purple },
  Define = { fg = c.purple },
  Error = { fg = c.purple },
  Macro = { fg = c.red },
  Special = { fg = c.red },
  SpecialChar = { fg = c.red },
  Tag = { fg = c.green },
  Delimiter = { fg = c.light_grey },

  -- treesitter, only where neovim's default links differ
  ['@punctuation'] = { fg = c.light_grey },
  ['@attribute'] = { fg = c.cyan },
  ['@attribute.builtin'] = { fg = c.blue },
  ['@comment'] = { fg = c.blue, italic = true },
  ['@comment.documentation'] = 'Comment',
  ['@comment.error'] = { fg = c.red, italic = true },
  ['@comment.note'] = { fg = c.blue, italic = true },
  ['@comment.todo'] = { fg = c.purple, italic = true },
  ['@comment.warning'] = { fg = c.yellow, italic = true },
  ['@conceal'] = { fg = c.grey },
  ['@constant'] = { fg = c.orange },
  ['@constant.builtin'] = { fg = c.orange },
  ['@constructor'] = { fg = c.yellow, bold = true },
  ['@function.builtin'] = { fg = c.cyan },
  ['@function.macro'] = { fg = c.cyan },
  ['@keyword.debug'] = { fg = c.red },
  ['@label'] = { fg = c.red },
  ['@markup.strong'] = { fg = c.fg, bold = true },
  ['@markup.italic'] = { fg = c.fg, italic = true },
  ['@markup.strikethrough'] = { fg = c.fg, strikethrough = true },
  ['@markup.underline'] = { fg = c.fg, underline = true },
  ['@markup.heading'] = { fg = c.orange, bold = true },
  ['@markup.heading.1'] = { fg = c.red, bold = true },
  ['@markup.heading.2'] = { fg = c.purple, bold = true },
  ['@markup.heading.4'] = { fg = c.red, bold = true },
  ['@markup.heading.5'] = { fg = c.purple, bold = true },
  ['@markup.link'] = { fg = c.blue },
  ['@markup.link.label'] = { fg = c.cyan },
  ['@markup.link.url'] = { fg = c.cyan, underline = true },
  ['@markup.list.checked'] = { fg = c.green, italic = true },
  ['@markup.list.unchecked'] = { fg = c.red, italic = true },
  ['@markup.math'] = { fg = c.fg },
  ['@markup.quote'] = { fg = c.grey, italic = true },
  ['@markup.raw'] = { fg = c.green },
  ['@module.builtin'] = { fg = c.orange },
  ['@none'] = { fg = c.fg },
  ['@operator'] = { fg = c.cyan },
  ['@property'] = { fg = c.cyan },
  ['@string.escape'] = { fg = c.red },
  ['@string.regexp'] = { fg = c.orange },
  ['@string.special'] = { fg = c.dark_cyan },
  ['@string.special.path'] = { fg = c.green },
  ['@string.special.symbol'] = { fg = c.cyan },
  ['@string.special.url'] = { fg = c.cyan, underline = true },
  ['@tag'] = { fg = c.purple },
  ['@tag.builtin'] = { fg = c.purple },
  ['@tag.attribute'] = { fg = c.yellow },
  ['@type.builtin'] = { fg = c.orange },
  ['@variable'] = { fg = c.fg },
  ['@variable.member'] = { fg = c.cyan },
  ['@variable.parameter'] = { fg = c.red },
  ['@variable.parameter.builtin'] = { fg = c.orange },

  -- lsp
  ['@lsp.type.builtinType'] = '@type.builtin',
  ['@lsp.type.comment'] = '@comment',
  ['@lsp.type.generic'] = { fg = c.red },
  ['@lsp.type.macro'] = '@function.macro',
  ['@lsp.type.property'] = { fg = c.red },
  ['@lsp.type.variable'] = { fg = c.yellow },
  ['@lsp.typemod.operator.injected'] = '@none',
  ['@lsp.typemod.variable.defaultLibrary'] = { fg = c.red },
  ['@lsp.typemod.variable.injected'] = '@variable',
  ['@lsp.typemod.variable.static'] = '@constant',
  LspReferenceText = { bg = c.bg2 },
  LspReferenceRead = { bg = c.bg2 },
  LspReferenceWrite = { bg = c.bg2 },
  LspCodeLens = { fg = c.grey, italic = true },
  LspCodeLensSeparator = { fg = c.grey },
  DiagnosticUnnecessary = { fg = c.grey },
  DiagnosticVirtualTextUnnecessary = { fg = c.grey, bg = darken(c.grey, 0.1) },
  DiagnosticUnderlineUnnecessary = { undercurl = true, sp = c.grey },
  DiagnosticDeprecated = { fg = c.orange, strikethrough = true },
  DiagnosticVirtualTextDeprecated = { fg = c.orange, bg = darken(c.orange, 0.1), strikethrough = true },
  DiagnosticUnderlineDeprecated = { strikethrough = true, sp = c.orange },

  -- ui
  ModeNormal = { fg = c.green, bg = c.bg1 },
  ModeInsert = { fg = c.blue, bg = c.bg1 },
  ModeVisual = { fg = c.purple, bg = c.bg1 },
  ModeCommand = { fg = c.red, bg = c.bg1 },
  ModeSelect = { fg = c.purple, bg = c.bg1 },
  ModeReplace = { fg = c.red, bg = c.bg1 },
  ModeTerminal = { fg = c.yellow, bg = c.bg1 },

  InclineNormal = { bg = c.bg1 },
  InclineNormalNC = { bg = c.bg1 },
  BufferCurrentMod = { fg = c.yellow, bold = true },
  TerminalWinbarFocus = { fg = c.black, bg = c.blue },

  -- plugins
  BlinkCmpMenu = { bg = c.bg1 },
  BlinkCmpMenuSelection = { bg = c.bg3 },
  BlinkCmpLabel = { fg = c.fg },
  BlinkCmpLabelMatch = { bold = true },
  BlinkCmpLabelDeprecated = { fg = c.light_grey, strikethrough = true },
  BlinkCmpLabelDetail = { fg = c.light_grey },
  BlinkCmpLabelDescription = { fg = c.light_grey },
  BlinkCmpDetail = { fg = c.light_grey },
  BlinkCmpGhostText = { fg = c.grey },
  BlinkCmpDoc = { bg = c.bg_d },
  BlinkCmpDocBorder = { bg = c.bg_d },
  BlinkCmpScrollBarThumb = { bg = c.grey },
  BlinkCmpScrollBarGutter = { bg = c.bg1 },

  MinibufferNormal = { fg = c.fg, bg = c.bg_d },
  MinibufferPrompt = { fg = c.yellow, bg = c.bg_d },
  MinibufferPath = { fg = colors.overlay_1, italic = true },
  MsgArea = { bg = c.bg_d }, -- ui2's cmdline, under the minibuffer's completions

  BlinkIndent = { fg = c.bg1 },
  BlinkIndentOrange = { fg = c.orange },
  BlinkIndentViolet = { fg = c.purple },
  BlinkIndentBlue = { fg = c.blue },
  BlinkPairsOrange = { fg = c.orange },
  BlinkPairsPurple = { fg = c.purple },
  BlinkPairsBlue = { fg = c.blue },
  BlinkPairsUnmatched = { fg = c.red },

  MiniCursorword = { underline = true },
  MiniCursorwordCurrent = { underline = true },
  MiniSurround = { fg = c.bg0, bg = c.orange },
  MiniIconsAzure = { fg = c.bg_blue },
  MiniIconsBlue = { fg = c.blue },
  MiniIconsCyan = { fg = c.cyan },
  MiniIconsGreen = { fg = c.green },
  MiniIconsGrey = { fg = c.fg },
  MiniIconsOrange = { fg = c.orange },
  MiniIconsPurple = { fg = c.purple },
  MiniIconsRed = { fg = c.red },
  MiniIconsYellow = { fg = c.yellow },

  OttoToolArg = { fg = c.light_grey },
  OttoToolSummary = { fg = c.light_grey },

  WhichKey = { fg = c.purple },
  WhichKeyBorder = { fg = c.bg_d, bg = c.bg_d },
  WhichKeyTitle = { fg = c.blue, bg = c.bg_d },
  WhichKeyGroup = { fg = c.grey },
  WhichKeyDesc = { fg = c.fg },
  WhichKeySeparator = { fg = c.grey },

  LiveRenameCurrent = { fg = c.blue, bg = c.diff_change },
  LiveRenameOther = { fg = c.red, bg = c.diff_delete },
}

-- { fg, virtual text, underline }
local severities = {
  Error = { c.red, c.dark_red, c.red },
  Warn = { c.yellow, c.dark_yellow, c.yellow },
  Info = { c.cyan, c.dark_cyan, c.blue },
  Hint = { c.purple, c.dark_purple, c.purple },
  Ok = { c.green, c.green, c.green },
}
for severity, color in pairs(severities) do
  hl['Diagnostic' .. severity] = { fg = color[1] }
  hl['DiagnosticVirtualText' .. severity] = { fg = color[2], bg = darken(color[2], 0.1) }
  hl['DiagnosticUnderline' .. severity] = { undercurl = true, sp = color[3] }
end

-- stylua: ignore
local kinds = {
  [c.purple] = { '', 'Default', 'Enum', 'Field', 'Struct', 'Variable' },
  [c.yellow] = { 'Array', 'Class', 'EnumMember', 'Event', 'Package' },
  [c.orange] = { 'Boolean', 'Constant', 'Folder', 'Module', 'Number', 'Reference', 'Value' },
  [c.green] = { 'Color', 'Interface', 'String', 'Unit' },
  [c.blue] = { 'Constructor', 'File', 'Function', 'Method' },
  [c.cyan] = { 'Key', 'Keyword', 'Property' },
  [c.red] = { 'Namespace', 'Object', 'Operator', 'Snippet', 'TypeParameter' },
  [c.grey] = { 'Null' },
  [c.light_grey] = { 'Text' },
}
for color, names in pairs(kinds) do
  for _, name in ipairs(names) do
    hl['BlinkCmpKind' .. name] = { fg = color }
  end
end

vim.cmd.highlight('clear')
vim.g.colors_name = 'tuque'
for name, spec in pairs(hl) do
  vim.api.nvim_set_hl(0, name, type(spec) == 'string' and { link = spec } or spec)
end

local term_colors = { c.black, c.red, c.green, c.yellow, c.blue, c.purple, c.cyan, c.fg }
for i = 0, 15 do
  vim.g['terminal_color_' .. i] = i == 8 and c.grey or term_colors[i % 8 + 1]
end
