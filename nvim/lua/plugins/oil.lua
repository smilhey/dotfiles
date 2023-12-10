return {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local permission_hlgroups = {
            ["-"] = "NonText",
            ["r"] = "DiagnosticSignWarn",
            ["w"] = "DiagnosticSignError",
            ["x"] = "DiagnosticSignOk",
        }
        require("oil").setup({
            view_options = {
                -- Show files and directories that start with "."
                show_hidden = true,
            },
            columns = {
                {
                    "permissions",
                },
                { "size",  highlight = "Special" },
                { "mtime", highlight = "Number" },
                {
                    "icon",
                    default_file = icon_file,
                    directory = icon_dir,
                    add_padding = false,
                },
            },
            win_options = {
                number = false,
                relativenumber = false,
                signcolumn = "no",
                foldcolumn = "0",
                statuscolumn = "",
            },
        })
        vim.keymap.set("n", "<leader>pv", "<cmd>Oil<CR>")
    end,
}
