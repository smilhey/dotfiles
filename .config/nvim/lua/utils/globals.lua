-- Global lua print function for lua objects
function P(object)
	print(vim.inspect(object))
end

-- Open a prompt UI and run a callback with the input
function Float_prompt(callback)
	local buffer = vim.api.nvim_create_buf(false, true)
	vim.bo[buffer].buftype = "prompt"

	local screen_width = vim.api.nvim_get_option_value("columns", {})
	local screen_height = vim.api.nvim_get_option_value("lines", {})
	local float_width = 20
	local float_height = 1
	local row = math.floor((screen_height - float_height) / 2)
	local col = math.floor((screen_width - float_width) / 2)

	local float = vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		width = float_width,
		height = float_height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	})
	vim.cmd("startinsert")
	vim.fn.prompt_setprompt(buffer, "> ")
	vim.fn.prompt_setcallback(buffer, function(input)
		callback(input)
		vim.api.nvim_win_close(float, true)
		vim.api.nvim_buf_delete(buffer, { force = true })
	end)
	vim.fn.prompt_setinterrupt(buffer, function()
		vim.api.nvim_win_close(float, true)
		vim.api.nvim_buf_delete(buffer, { force = true })
	end)
end
