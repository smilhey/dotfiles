local function hsl(h, s, l)
	s = s / 100
	l = l / 100
	local c = (1 - math.abs(2 * l - 1)) * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = l - c / 2
	local r1, g1, b1
	if h < 60 then
		r1, g1, b1 = c, x, 0
	elseif h < 120 then
		r1, g1, b1 = x, c, 0
	elseif h < 180 then
		r1, g1, b1 = 0, c, x
	elseif h < 240 then
		r1, g1, b1 = 0, x, c
	elseif h < 300 then
		r1, g1, b1 = x, 0, c
	else
		r1, g1, b1 = c, 0, x
	end
	local function tohex(number)
		return string.format("%02x", number)
	end
	local r = tohex(math.floor((r1 + m) * 255))
	local g = tohex(math.floor((g1 + m) * 255))
	local b = tohex(math.floor((b1 + m) * 255))
	return "#" .. r .. g .. b
end

local base = hsl(0, 0, 10) -- hsl(0, 0%, 7%)
local base100 = hsl(0, 0, 20) -- hsl(0, 0%, 20%)

-- local light = hsl(360, 20, 94) -- hsl(0, 20%, 92%)
local light = hsl(360, 15, 85) -- hsl(360, 15%, 85%)
local light100 = hsl(360, 20, 80) -- hsl(0, 20%, 80%)

local red = hsl(360, 70, 69) -- hsl(360, 70%, 69%)
local red100 = hsl(360, 70, 83) -- hsl(360, 70%, 83%)

local orange = hsl(30, 80, 69) -- hsl(30, 90%, 69%)
local orange100 = hsl(30, 95, 63) -- hsl(30, 95%, 63%)

local yellow = hsl(60, 50, 69) -- hsl(60, 50%, 69%)
local yellow100 = hsl(60, 50, 83) -- hsl(60, 50%, 83%)

local green = hsl(120, 60, 80) -- hsl(120, 60%, 80%)
local green900 = hsl(120, 60, 70) -- hsl(120, 60%, 70%)

local blue = hsl(210, 37, 59) -- hsl(210, 37%, 59%)
local blue100 = hsl(210, 50, 69) -- hsl(210, 50%, 79%)

local violet = hsl(270, 20, 60) -- hsl(270, 40%, 60%)
local violet100 = hsl(270, 30, 70) -- hsl(270, 50%, 80%)

local highlights = {
	Normal = { bg = base, fg = light },
	NormalFloat = { fg = light },
	FloatShadow = { bg = "black", blend = 80 },
	FloatShadowThrough = { bg = "black", blend = 100 },
	StatusLine = { bg = light, fg = base },
	WinSeparator = { fg = light },
	MsgSeparator = { fg = light },
	TabLine = {},
	TabLineSel = { fg = base, bg = light100 },
	TabLineFill = { link = "Normal" },
	WinBar = {},
	Title = { bg = light100, fg = base, bold = true },
	Visual = { bg = red100, fg = base },
	SignColumn = { bg = "None", fg = "None" },
	Underlined = { underline = true },
	Incsearch = { link = "Visual" },
	WarningMsg = { fg = orange100 },
	Search = { fg = "#1c1c1c", bg = blue100 },
	CurSearch = { fg = "#1c1c1c", bg = green900 },
	CursorLineNr = { fg = red, bold = true },
	LineNr = { fg = "#585858" },
	LineNrAbove = { fg = "#585858" },
	LineNrBelow = { fg = "#585858" },

	Error = { fg = base, bg = red },
	ErrorMsg = { link = "Error" },

	Todo = { bg = yellow, fg = "#1C1C1C", bold = true },
	MatchParen = { fg = red, bold = true },
	Function = { fg = yellow100 },
	Special = { link = "Function" },
	Statement = { fg = violet, bold = true },
	Keyword = { link = "Statement" },
	String = { fg = green },
	Constant = { fg = red, bold = true },
	Identifier = { fg = light },
	Character = { link = "String" },
	PreProc = { fg = yellow100, bold = true },
	Type = { fg = blue },
	Debug = { fg = violet },
	Comment = { fg = "#767676" },
	TermCursor = { reverse = true },
	NonText = { fg = "#585858" },
	Directory = { fg = blue, bold = true },

	DiagnosticInfo = { fg = blue },
	DiagnosticWarning = { fg = orange100 },
	DiagnosticError = { fg = red },
	DiagnosticWarn = { fg = orange100 },
	DiagnosticHint = { fg = light100 },
	DiagnosticOk = { fg = green900 },
	DiagnosticUnderlineError = { sp = red, underline = true },
	DiagnosticUnderlineWarn = { sp = orange100, underline = true },
	DiagnosticUnderlineInfo = { sp = blue100, underline = true },
	DiagnosticUnderlineHint = { sp = light100, underline = true },
	DiagnosticUnderlineOk = { sp = green900, underline = true },

	MoreMsg = { fg = "#87af87" },
	ModeMsg = { fg = "#1c1c1c", bg = "#d7d787" },
	Question = { fg = "#afaf87" },
	DiffAdd = { fg = "#000000", bg = green },
	DiffChange = { fg = "#000000", bg = light100 },
	DiffDelete = { fg = "#000000", bg = red100 },
	DiffText = { fg = "#000000", bg = "#d7d7d7" },
	Conceal = { fg = "#767676" },
	SpellBad = { sp = red, undercurl = true },
	SpellCap = { sp = blue, undercurl = true },
	SpellRare = { sp = violet, undercurl = true },
	SpellLocal = { sp = green900, undercurl = true },
	Pmenu = { link = "Normal" },
	PmenuSel = { link = "Visual" },
	PmenuSbar = { bg = "#cccccc" },
	PmenuThumb = { bg = "#767676" },
	CursorColumn = { bg = "#303030" },
	CursorLine = { bg = "#303030" },
	ColorColumn = { bg = "#262626" },
	QuickFixLine = { fg = base, bg = blue },
	Cursor = { fg = "#1c1c1c", bg = "#ffaf5f" },
	lCursor = { fg = "#1c1c1c", bg = "#5fff00" },
	SbarThumb = { bg = "#e77979", fg = "#eeeeee" },
	Sbar = {},

	RedrawDebugNormal = { reverse = true },
	RedrawDebugClear = { bg = yellow },
	RedrawDebugComposed = { bg = green900 },
	RedrawDebugRecompose = { bg = "red" },

	StatusLineNC = { fg = "#1c1c1c", bg = "#767676" },
	VertSplit = { fg = "#767676", bg = "#767676" },
	WildMenu = { fg = "#1c1c1c", bg = "#d7d787" },
	Folded = { fg = "#9e9e9e", bg = "#262626" },
	FoldColumn = { fg = "#585858" },
}

local highlights_links = {
	NvimInvalidSpacing = { link = "ErrorMsg" },
	LazyTaskError = { link = "ErrorMsg" },
	Substitute = { link = "Search" },
	LazyProgressTodo = { link = "LineNr" },
	StatusLineTerm = { link = "StatusLine" },
	StatusLineTermNC = { link = "StatusLineNC" },
	FloatTitle = { link = "Title" },
	LazyCommitType = { link = "Title" },
	NullLsInfoSources = { link = "Title" },
	LspInfoTitle = { link = "Title" },
	gitCommitSummary = { link = "Title" },
	LazyButtonActive = { link = "Visual" },
	CursorLineFold = { link = "FoldColumn" },
	LazyProp = { link = "Conceal" },
	LazyDimmed = { link = "Conceal" },
	PmenuKind = { link = "Pmenu" },
	PmenuExtra = { link = "Pmenu" },
	MessageWindow = { link = "Pmenu" },
	PmenuKindSel = { link = "PmenuSel" },
	PmenuExtraSel = { link = "PmenuSel" },
	LazyButton = { link = "CursorLine" },
	WinBarNC = { link = "WinBar" },
	NvimSpacing = { link = "Normal" },
	Terminal = { link = "Normal" },
	vimVar = { link = "Normal" },
	vimOper = { link = "Normal" },
	vimSep = { link = "Normal" },
	vimParenSep = { link = "Normal" },
	NvimInvalid = { link = "Error" },
	luaParenError = { link = "Error" },
	luaError = { link = "Error" },
	["@text.todo"] = { link = "Todo" },
	luaTodo = { link = "Todo" },
	PopupNotification = { link = "Todo" },
	["@string"] = { link = "String" },
	NvimString = { link = "String" },
	markdownUrl = { link = "String" },
	luaString2 = { link = "String" },
	luaString = { link = "String" },
	Number = { link = "Constant" },
	Boolean = { link = "Constant" },
	["@constant"] = { link = "Constant" },
	LazyProgressDone = { link = "Constant" },
	LazyReasonEvent = { link = "Constant" },
	luaConstant = { link = "Constant" },
	["@character"] = { link = "Character" },
	LazyReasonFt = { link = "Character" },
	LazyReasonSource = { link = "Character" },
	["@text.reference"] = { link = "Identifier" },
	["@parameter"] = { link = "Identifier" },
	["@field"] = { link = "Identifier" },
	["@property"] = { link = "Identifier" },
	["@variable"] = { link = "Identifier" },
	["@namespace"] = { link = "Identifier" },
	NvimIdentifier = { link = "Identifier" },
	LazyReasonImport = { link = "Identifier" },
	luaFunc = { link = "Identifier" },
	Conditional = { link = "Statement" },
	Repeat = { link = "Statement" },
	Label = { link = "Statement" },
	Operator = { link = "Statement" },
	Keyword = { link = "Statement" },
	Exception = { link = "Statement" },
	LazyReasonKeys = { link = "Statement" },
	luaStatement = { link = "Statement" },
	Include = { link = "PreProc" },
	Define = { link = "PreProc" },
	Macro = { link = "PreProc" },
	PreCondit = { link = "PreProc" },
	["@preproc"] = { link = "PreProc" },
	StorageClass = { link = "Type" },
	Structure = { link = "Type" },
	Typedef = { link = "Type" },
	["@type"] = { link = "Type" },
	NvimNumberPrefix = { link = "Type" },
	NvimOptionSigil = { link = "Type" },
	NullLsInfoTitle = { link = "Type" },
	LspInfoFiletype = { link = "Type" },
	Tag = { link = "Special" },
	SpecialChar = { link = "Special" },
	Delimiter = { link = "Special" },
	SpecialComment = { link = "Special" },
	["@constructor"] = { link = "Special" },
	LazyReasonPlugin = { link = "Special" },
	["@debug"] = { link = "Debug" },
	DiagnosticVirtualTextError = { link = "DiagnosticError" },
	DiagnosticFloatingError = { link = "DiagnosticError" },
	DiagnosticSignError = { link = "DiagnosticError" },
	DiagnosticVirtualTextWarn = { link = "DiagnosticWarn" },
	DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
	DiagnosticSignWarn = { link = "DiagnosticWarn" },
	LazyNoCond = { link = "DiagnosticWarn" },
	DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },
	DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
	DiagnosticSignInfo = { link = "DiagnosticInfo" },
	DiagnosticVirtualTextHint = { link = "DiagnosticHint" },
	DiagnosticFloatingHint = { link = "DiagnosticHint" },
	DiagnosticSignHint = { link = "DiagnosticHint" },
	DiagnosticVirtualTextOk = { link = "DiagnosticOk" },
	DiagnosticFloatingOk = { link = "DiagnosticOk" },
	DiagnosticSignOk = { link = "DiagnosticOk" },
	["@text.literal"] = { link = "Comment" },
	["@comment"] = { link = "Comment" },
	LazyComment = { link = "Comment" },
	luaComment = { link = "Comment" },
	LspInfoTip = { link = "Comment" },
	vimCommentString = { link = "Comment" },

	["@lsp.type.namespace"] = { link = "@namespace", default = true },
	["@lsp.type.class"] = { link = "@type", default = true },
	["@lsp.type.enum"] = { link = "@type", default = true },
	["@lsp.type.interface"] = { link = "@type", default = true },
	["@lsp.type.struct"] = { link = "@structure", default = true },
	["@lsp.type.parameter"] = { link = "@parameter", default = true },
	["@lsp.type.variable"] = { link = "@variable", default = true },
	["@lsp.type.property"] = { link = "@property", default = true },
	["@lsp.type.enumMember"] = { link = "@constant", default = true },
	["@lsp.type.function"] = { link = "@function", default = true },
	["@lsp.type.method"] = { link = "@method", default = true },
	["@lsp.type.macro"] = { link = "@macro", default = true },
	["@lsp.type.decorator"] = { link = "@function", default = true },
	["@lsp.type.type"] = { link = "@type", default = true },
	["@lsp.type.constant"] = { link = "@constant", default = true },

	-- ["@lsp.type.namespace"] = {},
	-- ["@lsp.type.class"] = {},
	-- ["@lsp.type.enum"] = {},
	-- ["@lsp.type.interface"] = {},
	-- ["@lsp.type.struct"] = {},
	-- ["@lsp.type.parameter"] = {},
	-- ["@lsp.type.variable"] = {},
	-- ["@lsp.type.property"] = {},
	-- ["@lsp.type.enumMember"] = {},
	-- ["@lsp.type.function"] = {},
	-- ["@lsp.type.method"] = {},
	-- ["@lsp.type.macro"] = {},
	-- ["@lsp.type.decorator"] = {},
	-- ["@lsp.type.type"] = {},
	-- ["@lsp.type.constant"] = {},

	NeogitDiffAdd = { link = "DiffAdd" },
	NeogitDiffDelete = { link = "DiffDelete" },
	NeogitDiffAddHighlight = { link = "DiffAdd" },
	NeogitDiffDeleteHighlight = { link = "DiffDelete" },
}

local function apply_colorscheme()
	vim.cmd("hi clear")
	for group, hi in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, hi)
	end
	for group, hi in pairs(highlights_links) do
		vim.api.nvim_set_hl(0, group, hi)
	end
	if vim.o.termguicolors or vim.o.guicursor then
		local terminal_ansi_colors = {
			base,
			red,
			green900,
			yellow,
			blue,
			violet,
			"#5f8787",
			light100,
			base100,
			orange100,
			green,
			yellow100,
			blue100,
			violet100,
			"#87afaf",
			light,

			-- "#1c1c1c",
			-- "#d75f5f",
			-- "#87af87",
			-- "#afaf87",
			-- "#5f87af",
			-- "#af87af",
			-- "#5f8787",
			-- "#9e9e9e",
			-- "#767676",
			-- "#d7875f",
			-- "#afd7af",
			-- "#d7d787",
			-- "#87afd7",
			-- "#d7afd7",
			-- "#87afaf",
			-- "#bcbcbc",
		}
		for i = 1, #terminal_ansi_colors do
			vim.g["terminal_color_" .. i - 1] = terminal_ansi_colors[i]
		end
	end
end

return apply_colorscheme
