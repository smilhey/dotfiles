vim.cmd("colorscheme habamax")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
vim.api.nvim_set_hl(0, "@variable", {})
vim.api.nvim_set_hl(0, "@lsp.type.variable", {})

vim.opt.termguicolors = true
vim.opt.wildoptions = "tagfile"

vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.cmdwinheight = 2

vim.env.PATH = vim.env.PATH
	.. ":/home/smilhey/miniforge3/condabin"
	.. ":/home/smilhey/.opam/default/bin"
	.. ":/home/smilhey/.cabal/bin"
	.. ":/home/smilhey/.ghcup/bin"
	.. ":/home/smilhey/.nvm/versions/node/v21.5.0/bin"
	.. ":/home/smilhey/.local/bin"
	.. ":/home/smilhey/.zig"
	.. ":/home/smilhey/.cargo/bin"
	.. ":/home/smilhey/.emacs.d/bin/"

vim.opt.autochdir = false
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.mouse = ""
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.clipboard = "unnamedplus"

-- vim.opt.colorcolumn = "80"
-- vim.cmd([[hi ColorColumn ctermbg=lightgrey guibg=#ebdbb2]])

vim.opt.spelllang = "en_us,fr"
vim.opt.spell = false
