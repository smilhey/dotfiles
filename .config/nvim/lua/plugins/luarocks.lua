return {
	"vhyrro/luarocks.nvim",
	priority = 1000, -- We'd like this plugin to load first out of the rest
	config = true, -- This automatically runs `require("luarocks-nvim").setup()`
	opts = {
		rocks = { "magick" }, -- specifies a list of rocks to install
		-- luarocks_build_args = { "--with-lua=/my/path" }, -- extra options to pass to luarocks's configuration script
	},
}
