return {
    "dccsillag/magma-nvim",
    config = function()
        -- Key mappings
        vim.keymap.set("n", "<space>r", "<cmd>MagmaEvaluateOperator<CR>", { silent = true, expr = true })
        vim.keymap.set("n", "<space>rr", "<cmd>MagmaEvaluateLine<CR>", { silent = true })
        vim.keymap.set("x", "<space>r", "<cmd>MagmaEvaluateVisual<CR>", { silent = true })
        vim.keymap.set("n", "<space>rc", "<cmd>MagmaReevaluateCell<CR>", { silent = true })
        vim.keymap.set("n", "<space>rd", "<cmd>MagmaDelete<CR>", { silent = true })
        vim.keymap.set("n", "<space>ro", "<cmd>MagmaShowOutput<CR>", { silent = true })

        -- Settings
        vim.g.magma_automatically_open_output = true
        vim.g.magma_image_provider = "kitty"
        -- Define a custom function to select and evaluate the block between ampersands
        function MagmaEvaluateBlock()
            -- Search for the "```python" code block
            local python_start_pos = vim.fn.search("```python", "bn")
            local python_end_pos = vim.fn.search("```", "n")

            if python_start_pos ~= 0 then
                -- Use the "```python" code block if found
                vim.fn.setpos(".", { 0, python_start_pos + 1, 1, 0 })
                vim.api.nvim_input("V")

                for i = python_start_pos + 1, python_end_pos - 2, 1 do
                    vim.api.nvim_input("j")
                end
                vim.cmd("MagmaEvaluateVisual")
            else
                -- If no "```python" code block, try to find "# %%" blocks
                local start_pos = vim.fn.search("# %%", "bn")
                local end_pos = vim.fn.search("# %%", "n")

                if start_pos ~= 0 and end_pos ~= 0 then
                    -- Use visual mode to select the text between # %%
                    vim.fn.setpos(".", { 0, start_pos + 1, 1, 0 })
                    vim.api.nvim_input("V")

                    for i = start_pos + 1, end_pos - 2, 1 do
                        vim.api.nvim_input("j")
                    end
                    vim.cmd("MagmaEvaluateVisual")
                else
                    print("No valid code block found")
                    return
                end
            end
        end

        -- function MagmaEvaluateBlock()
        -- 	local start_pos = vim.fn.search("# %%", "bn")
        -- 	local end_pos = vim.fn.search("# %%", "n")
        -- 	-- Use visual mode to select the text between %%
        -- 	vim.fn.setpos(".", { 0, start_pos + 1, 1, 0 })
        -- 	vim.api.nvim_input("V")
        --
        -- 	for i = start_pos + 1, end_pos - 2, 1 do
        -- 		vim.api.nvim_input("j")
        -- 	end
        -- 	-- Evaluate the selected block using MagmaEvaluateVisual
        -- 	vim.cmd("MagmaEvaluateVisual")
        -- end
        --
        -- Define a command to trigger the custom function
        vim.cmd("command! -nargs=0 MagmaEvaluateBlock lua MagmaEvaluateBlock()")

        -- Map a key combination to trigger the custom command
        vim.keymap.set("n", "<space>e", "<cmd>MagmaEvaluateBlock<CR>", { silent = true })
    end,
}
