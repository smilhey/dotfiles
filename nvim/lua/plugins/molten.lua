return {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    init = function()
        vim.g.molten_output_virt_lines = true
        vim.g.molten_output_win_max_height = 20
        vim.g.molten_image_provider = "image.nvim"
        vim.g.molten_auto_open_output = true
    end,
    config = function()
        --key mappings
        vim.keymap.set("n", "<localleader>ip", function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv ~= nil then
                -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
                venv = string.match(venv, "/.+/(.+)")
                vim.cmd(("MoltenInit %s"):format(venv))
            else
                vim.cmd("MoltenInit python3")
            end
        end, { desc = "Initialize Molten for python3", silent = true, noremap = true })
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
                vim.fn.MoltenEvaluateRange(python_start_pos, python_end_pos)
            else
                -- If no "```python" code block, try to find "# %%" blocks
                local start_pos = vim.fn.search("# %%", "bn")
                local end_pos = vim.fn.search("# %%", "n")

                if start_pos ~= 0 and end_pos ~= 0 then
                    vim.fn.MoltenEvaluateRange(start_pos, end_pos)
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

-- return {
-- 	"dccsillag/magma-nvim",
-- 	config = function()
-- 		-- Key mappings
-- 		vim.keymap.set("n", "<space>r", "<cmd>MagmaEvaluateOperator<CR>", { silent = true, expr = true })
-- 		vim.keymap.set("n", "<space>rr", "<cmd>MagmaEvaluateLine<CR>", { silent = true })
-- 		vim.keymap.set("x", "<space>r", "<cmd>MagmaEvaluateVisual<CR>", { silent = true })
-- 		vim.keymap.set("n", "<space>rc", "<cmd>MagmaReevaluateCell<CR>", { silent = true })
-- 		vim.keymap.set("n", "<space>rd", "<cmd>MagmaDelete<CR>", { silent = true })
-- 		vim.keymap.set("n", "<space>ro", "<cmd>MagmaShowOutput<CR>", { silent = true })
--
-- 		-- Settings
-- 		vim.g.magma_automatically_open_output = true
-- 		vim.g.magma_image_provider = "kitty"
-- 		-- Define a custom function to select and evaluate the block between ampersands
-- 		function MagmaEvaluateBlock()
-- 			-- Search for the "```python" code block
-- 			local python_start_pos = vim.fn.search("```python", "bn")
-- 			local python_end_pos = vim.fn.search("```", "n")
--
-- 			if python_start_pos ~= 0 then
-- 				-- Use the "```python" code block if found
-- 				vim.fn.setpos(".", { 0, python_start_pos + 1, 1, 0 })
-- 				vim.api.nvim_input("V")
--
-- 				for i = python_start_pos + 1, python_end_pos - 2, 1 do
-- 					vim.api.nvim_input("j")
-- 				end
-- 				vim.cmd("MagmaEvaluateVisual")
-- 			else
-- 				-- If no "```python" code block, try to find "# %%" blocks
-- 				local start_pos = vim.fn.search("# %%", "bn")
-- 				local end_pos = vim.fn.search("# %%", "n")
--
-- 				if start_pos ~= 0 and end_pos ~= 0 then
-- 					-- Use visual mode to select the text between # %%
-- 					vim.fn.setpos(".", { 0, start_pos + 1, 1, 0 })
-- 					vim.api.nvim_input("V")
--
-- 					for i = start_pos + 1, end_pos - 2, 1 do
-- 						vim.api.nvim_input("j")
-- 					end
-- 					vim.cmd("MagmaEvaluateVisual")
-- 				else
-- 					print("No valid code block found")
-- 					return
-- 				end
-- 			end
-- 		end
--
-- 		-- Define a command to trigger the custom function
-- 		vim.cmd("command! -nargs=0 MagmaEvaluateBlock lua MagmaEvaluateBlock()")
--
-- 		-- Map a key combination to trigger the custom command
-- 		vim.keymap.set("n", "<space>e", "<cmd>MagmaEvaluateBlock<CR>", { silent = true })
-- 	end,
-- }
