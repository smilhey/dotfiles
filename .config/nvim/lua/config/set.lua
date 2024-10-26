local apply_colorscheme = require("config.ui.colorscheme")

vim.opt.guicursor = "a:block-blinkon0,i:Cursor,r-cr-o:hor20,c:Cursor,ci:Cursor,cr:Cursor"
vim.g.mapleader = " "

vim.opt.termguicolors = true
vim.opt.pumblend = 0

vim.opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
	vert = "┃",
	horiz = "━",
	verthoriz = "╋",
	horizup = "┻",
	horizdown = "┳",
	vertleft = "┫",
	vertright = "┣",
}
vim.opt.list = true

-- vim.opt.wildoptions = "tagfile"
vim.opt.laststatus = 3
vim.opt.cmdheight = 1
vim.opt.cmdwinheight = 2
vim.opt.showcmd = false
vim.opt.showcmdloc = "statusline"
vim.opt.showmode = false
vim.opt.statusline = require("config.ui.statusline")
vim.opt.tabline = require("config.ui.tabline")
vim.opt.showtabline = 2
vim.opt_local.winbar = "%#StatusLine# %n %*%=%m %f"
vim.opt.shortmess = "aoOstTIcCFqS"

vim.env.PATH = vim.env.PATH
	.. ":/home/smilhey/miniforge3/condabin"
	.. ":/home/smilhey/.opam/default/bin"
	.. ":/home/smilhey/.cabal/bin"
	.. ":/home/smilhey/.ghcup/bin"
	.. ":/home/smilhey/.nvm/versions/node/v21.5.0/bin"
	.. ":/home/smilhey/.local/bin"
	.. ":/home/smilhey/.zig"
	.. ":/home/smilhey/.cargo/bin"

vim.opt.autochdir = false
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

vim.opt.mouse = ""
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.smoothscroll = true
vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.inccommand = "nosplit"

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.clipboard = "unnamedplus"

vim.opt.spelllang = "en_us,fr"
vim.opt.spell = false
vim.opt.completeopt = "menuone,popup,noinsert,fuzzy"

vim.opt.jumpoptions = "clean"
vim.opt.conceallevel = 2
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- habamax colorscheme

-- vim.cmd("colorscheme habamax")
-- -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "Function", { ctermfg = 109, fg = "#87afaf" })
-- vim.api.nvim_set_hl(0, "Module", { ctermfg = 109, fg = "#87afaf" })
-- vim.api.nvim_set_hl(0, "Identifier", { fg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
-- vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
-- vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none", fg = "none" })
-- vim.api.nvim_set_hl(0, "MsgSeparator", { bg = "none", fg = "none", underline = true })
-- vim.api.nvim_set_hl(0, "Statusline", { bg = "none" })
-- -- vim.api.nvim_set_hl(0, "@variable", {})
-- -- vim.api.nvim_set_hl(0, "@lsp.type.variable", {})
