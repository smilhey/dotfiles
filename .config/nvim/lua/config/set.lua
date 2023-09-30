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

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.clipboard = "unnamedplus"

vim.opt.colorcolumn = "80"
vim.cmd([[hi ColorColumn ctermbg=lightgrey guibg=#ebdbb2]])

-- vim.opt.textwidth = 70
-- vim.opt.formatoptions = table.concat({
-- 	"1",
-- 	"q", -- continue comments with gq"
-- 	"c", -- Auto-wrap comments using textwidth
-- 	"r", -- Continue comments when pressing Enter
-- 	"n", -- Recognize numbered lists
-- 	"2", -- Use indent from 2nd line of a paragraph
-- 	"t", -- autowrap lines using text width value
-- 	"j", -- remove a comment leader when joining lines.
-- 	-- Only break if the line was not longer than 'textwidth' when the insert
-- 	-- started and only at a white character that has been entered during the
-- 	-- current insert command.
-- 	"lv",
-- })
--
--

vim.opt.spelllang = "en_us,fr"
vim.opt.spell = true
