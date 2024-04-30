return {
	"benlubas/molten-nvim",
	lazy = true,
	build = ":UpdateRemotePlugins",
	init = function()
		vim.g.molten_virt_text_output = true
		vim.g.molten_output_virt_lines = true
		vim.g.molten_virt_lines_off_by_1 = true
		vim.g.molten_wrap_output = true
		vim.g.molten_auto_open_output = false
		vim.g.molten_auto_image_popup = false
		-- vim.g.molten_output_win_max_height = 20
		-- vim.g.molten_image_provider = "image.nvim"
		if not vim.g.neovide then
			vim.g.molten_image_provider = "image.nvim"
		end
	end,
	config = function()
		-- vim.api.nvim_set_hl(0, "MoltenVirtualText", { link = "Normal" })
		vim.keymap.set(
			"n",
			"<space>ip",
			":MoltenImagePopup<CR>",
			{ silent = true, noremap = true, desc = "image popup molten" }
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
		vim.keymap.set("n", "<space>e", function()
			local curpos = vim.fn.getpos(".")
			vim.cmd("MoltenEvaluateOperator")
			vim.api.nvim_input("ib")
			vim.schedule(function()
				vim.fn.setpos(".", curpos)
			end)
		end, { silent = true, noremap = true, desc = "evaluate cell" })

		function MoltenEvaluateAll()
			local query
			if vim.bo.filetype == "markdown" then
				_, query = pcall(
					vim.treesitter.query.parse,
					"markdown",
					[[
                (code_fence_content)  @codeblock
            ]]
				)
			else
				_, query = pcall(
					vim.treesitter.query.parse,
					"norg",
					[[
                (ranged_verbatim_tag_content)  @codeblock
            ]]
				)
			end
			local bufnr = vim.api.nvim_get_current_buf()
			local parser = vim.treesitter.get_parser(bufnr)
			local tree = parser:parse()
			local root = tree[1]:root()
			for _, match in query:iter_matches(root, bufnr) do
				for id, node in pairs(match) do
					local capture = query.captures[id]
					if capture == "codeblock" then
						local start_row, _, end_row, _ = node:range()
						vim.fn.MoltenEvaluateRange(start_row + 1, end_row)
					end
				end
			end
		end

		vim.api.nvim_create_user_command("MoltenEvaluateAll", MoltenEvaluateAll, {})

		-- automatically import output chunks from a jupyter notebook
		-- tries to find a kernel that matches the kernel in the jupyter notebook
		-- falls back to a kernel that matches the name of the active venv (if any)
		local imb = function(e) -- init molten buffer
			vim.schedule(function()
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
			end)
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
	end,
}
