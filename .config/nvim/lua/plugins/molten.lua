return {
	"benlubas/molten-nvim",
	build = ":UpdateRemotePlugins",
	init = function()
		vim.g.molten_virt_text_output = true
		vim.g.molten_output_virt_lines = true
		vim.g.molten_virt_lines_off_by_1 = true
		vim.g.molten_wrap_output = true
		vim.g.molten_auto_open_output = false
		-- vim.g.molten_output_win_max_height = 20
		-- vim.g.molten_image_provider = "image.nvim"
		if not vim.g.neovide then
			vim.g.molten_image_provider = "image.nvim"
		end
	end,
	config = function()
		vim.api.nvim_set_hl(0, "MoltenVirtualText", { link = "Normal" })

		--key mappings
		vim.keymap.set(
			"v",
			"<space>r",
			":<C-u>MoltenEvaluateVisual<CR>gv",
			{ silent = true, noremap = true, desc = "evaluate visual selection" }
		)
		vim.keymap.set(
			"n",
			"<space>rr",
			":MoltenEvaluateLine<CR>",
			{ silent = true, noremap = true, desc = "evaluate line" }
		)
		vim.keymap.set(
			"n",
			"<space>rc",
			":MoltenReevaluateCell<CR>",
			{ silent = true, noremap = true, desc = "re-evaluate cell" }
		)
		vim.keymap.set(
			"n",
			"<space>rd",
			":MoltenDelete<CR>",
			{ silent = true, noremap = true, desc = "molten delete cell" }
		)
		vim.keymap.set(
			"n",
			"<space>oh",
			":MoltenHideOutput<CR>",
			{ silent = true, noremap = true, desc = "hide output" }
		)
		vim.keymap.set(
			"n",
			"<space>os",
			":noautocmd MoltenEnterOutput<CR>",
			{ silent = true, noremap = true, desc = "show/enter output" }
		)

		local block_start = "```python\\|# %%\\|```{\\|@code"
		local block_end = "```\\|# %%\\|@end"

		function MoltenEvaluateBlock()
			local start_pos = vim.fn.search(block_start, "bn")
			local end_pos = vim.fn.search(block_end, "n")
			if start_pos ~= 0 and end_pos ~= 0 then
				vim.fn.MoltenEvaluateRange(start_pos + 1, end_pos - 1)
			else
				print("No valid code block found")
			end
		end

		function MoltenEvaluateAll()
			if pcall(vim.cmd, "vimgrep /" .. block_start .. "/gj %") then
				local quickfix_list = vim.fn.getqflist()
				local cursor_pos = vim.fn.getcurpos()

				for _, item in ipairs(quickfix_list) do
					vim.fn.cursor({ item.lnum, 0 })
					pcall(function()
						vim.fn.MoltenEvaluateRange(item.lnum + 1, vim.fn.search(block_end, "n") - 1)
					end)
				end
				vim.fn.setqflist({}, "r")
				vim.fn.setpos(".", cursor_pos)
			else
				vim.notify("No code cell to execute ", vim.log.levels.WARN)
			end
		end

		-- Define a command to trigger the custom function
		vim.api.nvim_create_user_command("MoltenEvaluateBlock", MoltenEvaluateBlock, {})
		vim.api.nvim_create_user_command("MoltenEvaluateAll", MoltenEvaluateAll, {})

		-- Map a key combination to trigger the custom command
		vim.keymap.set("n", "<space>e", MoltenEvaluateBlock, { silent = true })

		-- automatically import output chunks from a jupyter notebook
		-- tries to find a kernel that matches the kernel in the jupyter notebook
		-- falls back to a kernel that matches the name of the active venv (if any)
		local imb = function(e) -- init molten buffer
			local kernels = vim.fn.MoltenAvailableKernels()
			local try_kernel_name = function()
				local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
				return metadata.kernelspec.name
			end
			local ok, kernel_name = pcall(try_kernel_name)
			if not ok or not vim.tbl_contains(kernels, kernel_name) then
				kernel_name = nil
				local venv = os.getenv("VIRTUAL_ENV")
				if venv ~= nil then
					kernel_name = string.match(venv, "/.+/(.+)")
				end
			end
			if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
				vim.cmd(("MoltenInit %s"):format(kernel_name))
			end
			vim.cmd("MoltenImportOutput")
		end

		-- automatically import output chunks from a jupyter notebook
		vim.api.nvim_create_autocmd("BufAdd", {
			pattern = { "*.ipynb" },
			callback = imb,
		})

		-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = { "*.ipynb" },
			callback = function(e)
				if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
					imb(e)
				end
			end,
		})

		-- automatically export output chunks to a jupyter notebook on write
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.ipynb" },
			callback = function()
				if require("molten.status").initialized() == "Molten" then
					vim.cmd("MoltenExportOutput!")
				end
			end,
		})
	end,
}
