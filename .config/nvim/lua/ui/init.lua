local messages = require("ui.messages")
local cmdline = require("ui.cmdline")
local win_input = require("ui.input")
local win_select = require("ui.select")

vim.ui.input = function(opts, on_confirm)
	win_input(opts, on_confirm, { relative = "cursor", row = 1, col = 1 })
end

vim.ui.select = function(items, opts, on_choice)
	win_select(items, opts, on_choice, {})
end

messages.init()
cmdline.init()
