return {
	"benlubas/molten-nvim",
	build = ":UpdateRemotePlugins",
	init = function()
		vim.g.molten_output_virt_lines = true
		-- vim.g.molten_output_win_max_height = 20
		-- vim.g.molten_image_provider = "image.nvim"
		if not vim.g.neovide then
			vim.g.molten_image_provider = "image.nvim"
		end
		vim.g.molten_auto_open_output = true
	end,
	config = function()
		--key mappings
		vim.keymap.set(
			"n",
			"<space>i",
			":MoltenInit<CR>",
			{ silent = true, noremap = true, desc = "initialize molten" }
		)
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

		function MoltenEvaluateBlock()
			-- Search for the "```python" code block
			local python_start_pos = vim.fn.search("```python", "bn")
			local python_end_pos = vim.fn.search("```", "n")

			if python_start_pos ~= 0 then
				vim.fn.MoltenEvaluateRange(python_start_pos + 1, python_end_pos - 1)
			else
				-- If no "```python" code block, try to find "# %%" blocks
				local start_pos = vim.fn.search("# %%", "bn")
				local end_pos = vim.fn.search("# %%", "n")

				if start_pos ~= 0 and end_pos ~= 0 then
					vim.fn.MoltenEvaluateRange(start_pos + 1, end_pos - 1)
				else
					print("No valid code block found")
					return
				end
			end
		end

		-- Define a command to trigger the custom function
		vim.cmd("command! -nargs=0 MoltenEvaluateBlock lua MoltenEvaluateBlock()")

		-- Map a key combination to trigger the custom command
		vim.keymap.set("n", "<space>e", "<cmd>MoltenEvaluateBlock<CR>", { silent = true })
	end,
}
