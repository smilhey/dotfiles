-- vim.keymap.set("i", "(", "()<Left>")
-- vim.keymap.set("i", "[", "[]<Left>")
-- vim.keymap.set("i", "{", "{}<Left>")
-- vim.keymap.set("i", ")", "()<Left>")
-- vim.keymap.set("i", "]", "[]<Left>")
-- vim.keymap.set("i", "}", "{}<Left>")
-- vim.keymap.set("i", '"', '""<Left>')

vim.keymap.set("n", ":", "q:i")
vim.keymap.set("n", "?", "q?i")
vim.keymap.set("n", "/", "q/i")

vim.keymap.set("n", "q:", ":")
vim.keymap.set("n", "q?", "?")
vim.keymap.set("n", "q/", "/")

vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>bt", "<cmd>buffer term <Tab><CR>")
vim.keymap.set("n", "<C-w>[", "<cmd>lcd %:p:h | botright 10new +term<CR>")
vim.keymap.set("n", "<C-w>]", "<cmd>lcd %:p:h | vertical rightb 30new +term<CR>")
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

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
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("n", "<A-Tab>", "gt")
-- vim.g.copilot_no_tab_map = true
-- vim.g.copilot_assume_mapped = true

vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "0", "g0")
vim.keymap.set("n", "#", "g#")
