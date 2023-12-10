return {
    "jbyuki/nabla.nvim",
    config = function()
        vim.keymap.set("n", "<leader>ll", "<cmd>lua require('nabla').popup()<CR>", { noremap = true, silent = true })
    end,
}
