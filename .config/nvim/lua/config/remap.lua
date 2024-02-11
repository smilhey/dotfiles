-- resizing splits
vim.keymap.set("n", "<A-h>", "<C-W><C-<>")
vim.keymap.set("n", "<A-j>", "<C-W><C-->")
vim.keymap.set("n", "<A-k>", "<C-W><C-+>")
vim.keymap.set("n", "<A-l>", "<C-W><C->>")
-- moving between splits
vim.keymap.set("n", "<C-h>", "<C-W><C-h>")
vim.keymap.set("n", "<C-j>", "<C-W><C-j>")
vim.keymap.set("n", "<C-k>", "<C-W><C-k>")
vim.keymap.set("n", "<C-l>", "<C-W><C-l>")

vim.keymap.set("n", "]a", "<cmd>bnext<CR>", { silent = true })
vim.keymap.set("n", "[a", "<cmd>bprev<CR>", { silent = true })
vim.keymap.set("n", "]q", "<cmd>try | cnext | catch | cfirst | catch | endtry<CR><CR>", { silent = true })
vim.keymap.set("n", "[q", "<cmd>try | cprev | catch | clast | catch | endtry<CR><CR>", { silent = true })

-- vim.keymap.set("n", ":", "q:i")
-- vim.keymap.set("n", "?", "q?i")
-- vim.keymap.set("n", "/", "q/i")
--
-- vim.keymap.set("n", "q:", ":")
-- vim.keymap.set("n", "q?", "?")
-- vim.keymap.set("n", "q/", "/")

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
end)
vim.keymap.set("n", "<C-w>]", function()
	open_term("right")
end)
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.g.mapleader = " "
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "<C-b>", "<C-b>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Remapping esc
-- vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<A-Tab>", "gt")
-- vim.g.copilot_no_tab_map = true
-- vim.g.copilot_assume_mapped = true

vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "0", "g0")
vim.keymap.set("n", "#", "g#")
