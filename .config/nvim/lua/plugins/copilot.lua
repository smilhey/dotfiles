return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		event = "VeryLazy",
		branch = "canary",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
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
			local chat_cmds = {
				"CopilotChat",
				"CopilotChatOpen",
				"CopilotChatClose",
				"CopilotChatToggle",
				"CopilotChatReset",
				"CopilotChatSave",
				"CopilotChatLoad",
				"CopilotChatDebugInfo",
				"CopilotChatExplain",
				"CopilotChatReview",
				"CopilotChatFix",
				"CopilotChatOptimize",
				"CopilotChatDocs",
				"CopilotChatTests",
				"CopilotChatFixDiagnostic",
				"CopilotChatCommit",
				"CopilotChatCommitStaged",
			}
			for _, cmd in ipairs(chat_cmds) do
				vim.api.nvim_del_user_command(cmd)
			end

			vim.api.nvim_create_user_command("CopilotChat", function()
				chat.toggle()
			end, {})
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		config = function()
			require("copilot").setup({
				-- suggestion = { enabled = true, keymap = { accept = "<M-;>" } },
				suggestion = { enabled = false },
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
