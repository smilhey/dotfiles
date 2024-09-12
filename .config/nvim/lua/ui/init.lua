local messages = require("ui.messages")
local cmdwin = require("ui.cmdwin")
local cmdline = require("ui.cmdline")
local popupmenu = require("ui.popupmenu")
local win_input = require("ui.input")
local win_select = require("ui.select")
local scrollbar = require("ui.scrollbar")
local notify = require("ui.notify")
local lsp_progress = require("ui.lsp_progress")

vim.ui.input = function(opts, on_confirm)
	win_input(opts, on_confirm, { relative = "cursor", row = 1, col = 1 })
end

vim.ui.select = function(items, opts, on_choice)
	win_select(items, opts, on_choice, {})
end

messages.setup()
popupmenu.setup({})
cmdwin.setup()
scrollbar.setup()
notify.setup()
lsp_progress.setup()
-- cmdline.setup()

local function ui_cmd(args)
	local ui_element = args.fargs[1]
	if ui_element == "cmdline" then
		cmdwin.toggle()
	elseif ui_element == "popupmenu" then
		popupmenu.toggle()
	elseif ui_element == "messages" then
		messages.toggle()
	elseif ui_element == "scrollbar" then
		scrollbar.toggle()
	elseif ui_element == "notify" then
		notify.toggle()
	else
		vim.notify("No function arguments provided", vim.log.levels.WARN)
	end
end

local function ui_cmd_complete(ArgLead, _)
	local items = { "cmdline", "popupmenu", "messages", "scrollbar", "notify" }
	local completion_list = vim.tbl_filter(function(v)
		return string.find(v, "^" .. ArgLead) ~= nil
	end, items)
	return completion_list
end

vim.api.nvim_create_user_command("Ui", ui_cmd, { desc = "ui command", nargs = "?", complete = ui_cmd_complete })
