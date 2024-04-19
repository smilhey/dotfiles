vim.opt_local.foldlevel = 0
vim.opt_local.foldmethod = "expr"
vim.cmd(
	"setlocal foldexpr="
		.. "matchstr(getline(v:lnum),'^[^\\|]\\\\+')==#matchstr(getline(v:lnum+1),'^[^\\|]\\\\+')?1:'<1'"
)
