return {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
        -- LSP Support
        { "neovim/nvim-lspconfig" }, -- Required
        {
            -- Optional
            "williamboman/mason.nvim",
            build = function()
                pcall(vim.cmd, "MasonUpdate")
            end,
        },
        { "williamboman/mason-lspconfig.nvim" }, -- Optional

        -- Autocompletion
        { "hrsh7th/nvim-cmp" }, -- Required
        { "hrsh7th/cmp-nvim-lsp" }, -- Required
        {
            "L3MON4D3/LuaSnip",
            dependencies = "rafamadriz/friendly-snippets",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
            end,
        },
        { "hrsh7th/cmp-buffer" },
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-path" },
        { "onsails/lspkind-nvim" },
    },
    config = function()
        local lsp = require("lsp-zero")

        lsp.preset("recommended")

        lsp.ensure_installed({
            "lua_ls",
        })

        -- Fix Undefined global 'vim'
        lsp.configure("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                },
            },
        })
        lsp.configure("clangd", {
            cmd = {
                "clangd",
                "--offset-encoding=utf-16",
            },
        })

        local cmp = require("cmp")
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        local cmp_mappings = lsp.defaults.cmp_mappings({
            ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
            ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
            ["<C-y>"] = cmp.mapping.confirm({ select = true }),
            ["<C-Space>"] = cmp.mapping.complete(),
        })

        cmp_mappings["<Tab>"] = nil
        cmp_mappings["<S-Tab>"] = nil

        lsp.setup_nvim_cmp({
            mapping = cmp_mappings,
        })

        lsp.set_preferences({
            suggest_lsp_servers = false,
            sign_icons = {
                error = "E",
                warn = "W",
                hint = "H",
                info = "I",
            },
        })

        lsp.on_attach(function(client, bufnr)
            local opts = { buffer = bufnr, remap = false }

            vim.keymap.set("n", "gd", function()
                vim.lsp.buf.definition()
            end, opts)
            vim.keymap.set("n", "K", function()
                vim.lsp.buf.hover()
            end, opts)
            vim.keymap.set("n", "<leader>vws", function()
                vim.lsp.buf.workspace_symbol()
            end, opts)
            vim.keymap.set("n", "<leader>vd", function()
                vim.diagnostic.open_float()
            end, opts)
            vim.keymap.set("n", "[d", function()
                vim.diagnostic.goto_next()
            end, opts)
            vim.keymap.set("n", "]d", function()
                vim.diagnostic.goto_prev()
            end, opts)
            vim.keymap.set("n", "<leader>vca", function()
                vim.lsp.buf.code_action()
            end, opts)
            vim.keymap.set("n", "<leader>vrr", function()
                vim.lsp.buf.references()
            end, opts)
            vim.keymap.set("n", "<leader>vrn", function()
                vim.lsp.buf.rename()
            end, opts)
            vim.keymap.set("i", "<C-h>", function()
                vim.lsp.buf.signature_help()
            end, opts)
        end)

        lsp.setup()

        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            formatting = {
                format = lspkind.cmp_format({
                    with_text = true,
                    menu = {
                        path = "[path]",
                        copilot = "",
                        buffer = "[buf]",
                        nvim_lsp = "[LSP]",
                        luasnip = "[snip]",
                    },
                }),
            },
            sources = {
                { name = "nvim_lsp" },
                { name = "copilot" },
                { name = "path" },
                { name = "buffer",  keyword_length = 3 },
                { name = "luasnip", keyword_length = 2 },
            },
        })

        vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
        vim.diagnostic.config({
            virtual_text = true,
        })
    end,
}
