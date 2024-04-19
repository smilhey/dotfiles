return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		-- lazy = true,
		dependencies = {
			-- { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
			{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
		},
		config = function()
			local chat = require("CopilotChat")
			vim.keymap.set("n", "<leader>cc", function()
				chat.open({
					window = {
						layout = "float",
						relative = "editor",
						width = 0.45,
						height = 0.85,
						row = 1,
						col = 90,
					},
				})
			end, { desc = "Launch Copilot Chat" })
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					local cop_buffer = vim.api.nvim_get_current_buf()
					vim.keymap.set("n", "q", function()
						chat.close()
					end, { nowait = true, buffer = cop_buffer, desc = "Close Copilot Chat" })
				end,
			})
			require("CopilotChat").setup({
				show_help = false, -- Shows help message as virtual lines when waiting for user input
				mappings = {
					close = { insert = "", normal = "" },
					submit_prompt = { normal = "<CR>", insert = "<C-Enter>" },
					reset = { normal = "<M-r>", insert = "<M-r>" },
				},
			})

			vim.api.nvim_del_user_command("CopilotChat")
			vim.api.nvim_del_user_command("CopilotChatOpen")
			vim.api.nvim_del_user_command("CopilotChatClose")
			vim.api.nvim_del_user_command("CopilotChatToggle")
			vim.api.nvim_del_user_command("CopilotChatReset")
			vim.api.nvim_del_user_command("CopilotChatSave")
			vim.api.nvim_del_user_command("CopilotChatLoad")
			vim.api.nvim_del_user_command("CopilotChatDebugInfo")
			vim.api.nvim_del_user_command("CopilotChatExplain")
			vim.api.nvim_del_user_command("CopilotChatReview")
			vim.api.nvim_del_user_command("CopilotChatFix")
			vim.api.nvim_del_user_command("CopilotChatOptimize")
			vim.api.nvim_del_user_command("CopilotChatDocs")
			vim.api.nvim_del_user_command("CopilotChatTests")
			vim.api.nvim_del_user_command("CopilotChatFixDiagnostic")
			vim.api.nvim_del_user_command("CopilotChatCommit")
			vim.api.nvim_del_user_command("CopilotChatCommitStaged")

			vim.api.nvim_create_user_command("CopilotChat", function()
				chat.toggle()
			end, {})
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = true, keymap = { accept = "<M-;>" } },
				panel = { enabled = false },
				filetypes = {
					markdown = true,
				},
			})
		end,
		dependencies = {
			"zbirenbaum/copilot-cmp",
			config = function()
				require("copilot_cmp").setup()
			end,
		},
	},
}
