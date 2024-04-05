return {
	dir = "~/misc/cabinet.nvim",
	config = function()
		local cabinet = require("cabinet")
		cabinet:setup()
		require("telescope").load_extension("cabinet")
		local save = require("cabinet.save")
		save.save_cmd()
		save.load_cmd()

		vim.api.nvim_create_autocmd("User", {
			nested = true,
			pattern = "DrawAdd",
			callback = function(event)
				-- This is the name of the new drawer
				local new_drawnm = event.data
				cabinet.drawer_select(new_drawnm)
			end,
		})

		-- vim.api.nvim_create_autocmd("User", {
		-- 	nested = true,
		-- 	pattern = "DrawNewEnter",
		-- 	callback = function(event)
		-- 		vim.cmd("term")
		-- 	end,
		-- })

		vim.keymap.set("n", "<leader>dp", function()
			vim.cmd("DrawerPrevious")
		end)
		vim.keymap.set("n", "<leader>dn", function()
			vim.cmd("DrawerNext")
		end)
		vim.keymap.set("n", "<leader>dc", function()
			vim.cmd("DrawerNew")
		end)
		vim.keymap.set("n", "<leader>dr", function()
			vim.cmd("DrawerRename")
		end)
		vim.keymap.set("n", "<leader>dt", function()
			vim.cmd("Telescope cabinet")
		end)
	end,
}
