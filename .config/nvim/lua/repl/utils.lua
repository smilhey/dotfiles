local format = require("repl.format")
local M = {}

function M.get_repl(chan)
	local chan_info = vim.api.nvim_get_chan_info(chan)
	local argv = chan_info.argv
	for _, str in ipairs(argv) do
		local cmd = vim.fs.basename(str)
		if vim.tbl_contains(format.supported, cmd) then
			return cmd
		end
	end
	return nil
end

function M.send_selection(chan, selection, buf, mark)
	local repl = M.get_repl(chan)
	repl = repl and repl or "default"
	local data = format.input[repl](selection)
	data = (buf and mark) and format.pad(data, repl, buf, mark) or data
	vim.api.nvim_chan_send(chan, data)
end

return M
