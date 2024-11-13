local tabline = require("ui.tabline")
local messages = require("ui.messages")
local cmdline = require("ui.cmdline")
-- local cmdline = require("ui.cmdline")
local pumenu = require("ui.pumenu")
local win_input = require("ui.input").win_input
local win_select = require("ui.select")
local scrollbar = require("ui.scrollbar")
local notify = require("ui.notify")
-- local statusline = require("ui.statusline")
-- local lsp_progress = require("ui.lsp_progress")

vim.ui.input = function(opts, on_confirm)
	win_input(opts, on_confirm, {})
end

vim.ui.select = function(items, opts, on_choice)
	win_select(items, opts, on_choice, {})
end

local M = {}

M.ns = vim.api.nvim_create_namespace("UI")
M.cmdline, M.popupmenu, M.tabline, M.messages = true, true, true, true
M.disable =
	{ cmdline = cmdline.disable, tabline = tabline.disable, popupmenu = pumenu.disable, messages = function() end }
M.setup = { cmdline = cmdline.setup, tabline = tabline.setup, popupmenu = pumenu.setup, messages = messages.setup }

local function attach()
	vim.ui_attach(
		M.ns,
		{ ext_cmdline = M.cmdline, ext_popupmenu = M.popupmenu, ext_tabline = M.tabline, ext_messages = M.messages },
		function(event, ...)
			if event:match("cmdline") ~= nil and M.cmdline then
				cmdline.handler(event, ...)
				if vim.api.nvim_win_is_valid(pumenu.win) then
					pumenu.init_window()
					vim.api.nvim__redraw({ flush = true })
				end
			elseif event:match("msg") ~= nil and M.messages then
				messages.handler(event, ...)
			elseif event:match("popupmenu") ~= nil and M.popupmenu then
				pumenu.handler(event, ...)
			elseif event:match("tabline") ~= nil and M.tabline then
				tabline.handler(event, ...)
			end
		end
	)
end

local function detach()
	vim.ui_detach(M.ns)
end

local function toggle(ui_element)
	if M[ui_element] then
		M.disable[ui_element]()
	else
		M.setup[ui_element]()
	end
	M[ui_element] = not M[ui_element]
	detach()
	attach()
end

local function ui_cmd(args)
	local ui_element = args.fargs[1]
	if not ui_element or ui_element == "" then
		vim.notify("You need to specifiy the UI element to toggle", vim.log.levels.WARN)
		return
	end
	if ui_element == "scrollbar" then
		scrollbar.toggle()
	elseif ui_element == "notify" then
		notify.toggle()
	else
		toggle(ui_element)
	end
end

local function ui_cmd_complete(ArgLead, _)
	local items = { "cmdline", "popupmenu", "messages", "scrollbar", "notify", "tabline" }
	local completion_list = vim.tbl_filter(function(v)
		return string.find(v, "^" .. ArgLead) ~= nil
	end, items)
	return completion_list
end

vim.api.nvim_create_user_command("Ui", ui_cmd, { desc = "Toggle UI elements", nargs = "?", complete = ui_cmd_complete })

tabline.setup()
messages.setup()
pumenu.setup()
cmdline.setup()
scrollbar.setup()
notify.setup()
-- cmdline.setup()
-- lsp_progress.setup()
attach()
