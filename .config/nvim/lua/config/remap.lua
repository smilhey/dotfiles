-- some utils
vim.keymap.set("n", "<leader><leader>l", "<cmd>luafile %<CR>", { desc = "Run with lua current file" })
vim.keymap.set("n", "<leader><leader>s", "<cmd>source<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<C-e>", function()
	local result = vim.inspect_pos()
	local hl_ts = unpack(result.treesitter) and vim.inspect(unpack(result.treesitter).hl_group) or "nil"
	local hl_sx = unpack(result.syntax) and vim.inspect(unpack(result.syntax).hl_group) or "nil"
	local hl_st = unpack(result.semantic_tokens) and vim.inspect(unpack(result.semantic_tokens).opts.hl_group) or "nil"
	local print_result = ""
	for k, v in pairs({ ["Treesitter: "] = hl_ts, ["Syntax: "] = hl_sx, ["Semantic :"] = hl_st }) do
		print_result = v ~= "nil" and print_result .. k .. v .. " " or print_result
	end
	print_result = print_result ~= "" and print_result or "No highlight group found"
	print(print_result)
end, { noremap = true, silent = true, desc = "Get hl group at cursor" })
vim.keymap.set("i", "<A-BS>", "<C-w>", { desc = "Delete previous word in Insert mode ", silent = true })

-- wezterm integration
local function switch_pane(direction)
	local current_window = vim.api.nvim_get_current_win()
	local direction_table = { Left = "h", Down = "j", Up = "k", Right = "l" }
	vim.cmd("wincmd " .. direction_table[direction])
	if vim.env.TERM_PROGRAM == "WezTerm" and vim.api.nvim_get_current_win() == current_window then
		vim.system({ "wezterm", "cli", "activate-pane-direction", direction })
	end
end

-- resizing splits
vim.keymap.set("n", "<A-h>", "<C-W><C-<>", { desc = "Decrease horizontal", silent = true })
vim.keymap.set("n", "<A-j>", "<C-W><C-->", { desc = "Decrease vertical", silent = true })
vim.keymap.set("n", "<A-k>", "<C-W><C-+>", { desc = "Increase vertical", silent = true })
vim.keymap.set("n", "<A-l>", "<C-W><C->>", { desc = "Decrease horizontal", silent = true })
-- moving between splits
vim.keymap.set("n", "<C-h>", function()
	switch_pane("Left")
end, { desc = "Move to the left pane", silent = true })
vim.keymap.set("n", "<C-j>", function()
	switch_pane("Down")
end, { desc = "Move to the bottom pane", silent = true })
vim.keymap.set("n", "<C-k>", function()
	switch_pane("Up")
end, { desc = "Move to the top pane", silent = true })
vim.keymap.set("n", "<C-l>", function()
	switch_pane("Right")
end, { desc = "Move to the right pane", silent = true })

vim.keymap.set("n", "L", "<cmd>bnext<CR>", { desc = "Next Buffer", silent = true })
vim.keymap.set("n", "H", "<cmd>bprev<CR>", { desc = "Previous Buffer", silent = true })
vim.keymap.set(
	"n",
	"]q",
	"<cmd>try | cnext | catch | cfirst | catch | endtry<CR><CR>",
	{ desc = "quickfix next", silent = true }
)
vim.keymap.set(
	"n",
	"[q",
	"<cmd>try | cprev | catch | clast | catch | endtry<CR><CR>",
	{ desc = "quickfix previous", silent = true }
)

-- using cmdwindow as default
vim.keymap.set({ "n", "v" }, ":", "q:", { desc = "Switching cmdwin and cmdline", silent = true })
vim.keymap.set({ "n", "v" }, "?", "q?", { desc = "Switching cmdwin and cmdline", silent = true })
vim.keymap.set({ "n", "v" }, "/", "q/", { desc = "Switching cmdwin and cmdline", silent = true })
vim.keymap.set({ "n", "v" }, "!", "!<C-f>", { desc = "Switching cmdwin and cmdline" })

vim.keymap.set({ "n", "v" }, "q:", ":", { desc = "Switching cmdwin and cmdline", silent = true })
vim.keymap.set({ "n", "v" }, "q?", "?", { desc = "Switching cmdwin and cmdline", silent = true })
vim.keymap.set({ "n", "v" }, "q/", "/", { desc = "Switching cmdwin and cmdline", silent = true })

local open_term = function(direction)
	-- Check if there's a terminal buffer in the current workspace
	local term_buf_exists = false
	local path = string.gsub(vim.fn.expand("%:p:h"), "/home/smilhey", "")
	local buf_number = 0
	for _, buf_info in ipairs(vim.fn.getbufinfo({ buflisted = true })) do
		if vim.fn.match(buf_info.name, "term://") ~= -1 and vim.fn.match(buf_info.name, path) ~= -1 then
			term_buf_exists = true
			buf_number = buf_info.bufnr
			break
		end
	end

	if term_buf_exists then
		if direction == "down" then
			vim.cmd("botright 10new | b " .. tonumber(buf_number))
		elseif direction == "right" then
			vim.cmd("vertical rightb 30new | b" .. tonumber(buf_number))
		end
	else
		if direction == "down" then
			vim.cmd("lcd %:p:h | botright 10new +term")
		elseif direction == "right" then
			vim.cmd("lcd %:p:h | vertical rightb 30new +term")
		end
	end
end

vim.keymap.set("n", "<C-w>[", function()
	open_term("down")
end, { desc = "Open terminal below" })
vim.keymap.set("n", "<C-w>]", function()
	open_term("right")
end, { desc = "Open terminal right" })

-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half screen and center" })
vim.keymap.set("n", "<C-u>", "<C-u>z.", { desc = "Scroll up half screen and center" })
vim.keymap.set("n", "<C-f>", "<C-f>zz", { desc = "Scroll down full screen and center" })
vim.keymap.set("n", "<C-b>", "<C-b>zz", { desc = "Scroll up full screen and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Move to next search and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Move to previous search and center" })

-- Remapping esc
-- vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Remap <C-c> to <Esc>" })

vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Substitute word under cursor" }
)

vim.keymap.set("n", "<A-Tab>", "gt", { desc = "Switch to next tab" })
-- vim.g.copilot_no_tab_map = true
-- vim.g.copilot_assume_mapped = true
