local builtin_marks = { ".", "^", "`", "'", '"', "<", ">", "[", "]" }
for i = 1, 26 do
	local mark = string.char(string.byte("a") + i - 1)
	vim.fn.sign_define("mark-" .. mark, { text = mark, texthl = "DiagnosticInfo" })
end
for _, mark in ipairs(builtin_marks) do
	vim.fn.sign_define("mark-" .. mark, { text = mark, texthl = "DiagnosticInfo" })
end

local marklist = {}

local function refresh_buf_marks()
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()
	if vim.fn.win_gettype(win) ~= "" then
		return
	end
	local buf_marklist = vim.fn.getmarklist(buf)
	if marklist[buf] and vim.deep_equal(marklist[buf], buf_marklist) then
		return
	end
	marklist[buf] = buf_marklist
	vim.fn.sign_unplace("marks", { buffer = buf }) -- Clear old signs
	for _, item in ipairs(buf_marklist) do
		local mark = item.mark:sub(-1)
		vim.fn.sign_place(0, "marks", "mark-" .. mark, buf, { lnum = item.pos[2], priority = 20 })
	end
end

-- local timer = vim.uv.new_timer()
-- timer:start(0, 500, vim.schedule_wrap(refresh_buf_marks))
vim.api.nvim_create_autocmd("CursorMoved", { callback = refresh_buf_marks })

-- Now for global marks we want some visualisation

local function format_mark(item)
	return item.mark:sub(-1) .. " - " .. vim.fn.fnamemodify(item.file, ":~:.")
end

local function goto_mark(item)
	vim.schedule(function()
		vim.cmd("normal! '" .. item.mark:sub(-1))
	end)
end
local function del_mark(item)
	vim.cmd("delmark " .. item.mark:sub(-1))
end

local function filter_mark(item)
	return not item.mark:sub(-1):match("[0-9]")
end

-- vim.keymap.set("n", "<leader>ms", function()
-- 	vim.ui.select(
-- 		vim.tbl_filter(filter_mark, vim.fn.getmarklist()),
-- 		{ prompt = "Global Marks", format_item = format_mark },
-- 		goto_mark
-- 	)
-- end, { silent = true, desc = "Select a global mark" })
--
-- vim.keymap.set("n", "<leader>md", function()
-- 	vim.ui.select(
-- 		vim.tbl_filter(filter_mark, vim.fn.getmarklist()),
-- 		{ prompt = "Global Marks", format_item = format_mark },
-- 		function(choice)
-- 			vim.cmd("delmark " .. choice.mark:sub(-1))
-- 		end
-- 	)
-- end, { silent = true, desc = "Delete a global mark" })

local win_menu = require("ui.menu")
vim.keymap.set("n", "<leader>m", function()
	local marks = vim.tbl_filter(filter_mark, vim.fn.getmarklist())
	if vim.tbl_isempty(marks) then
		vim.notify("No marks set", vim.log.levels.INFO)
		return
	end
	win_menu(marks, format_mark, {
		["g"] = { desc = "Goto mark", fn = goto_mark, close = true },
		["d"] = { desc = "Delete mark", fn = del_mark, close = true },
	}, { desc = true, win_opts = { title = "Global Marks" } })
end, { silent = true, desc = "Select or delet global mark" })
