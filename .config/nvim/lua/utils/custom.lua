function P(object)
	print(vim.inspect(object))
end

function T(tui)
	local buffer = vim.api.nvim_create_buf(false, true)

	local screen_width = vim.api.nvim_get_option("columns")
	local screen_height = vim.api.nvim_get_option("lines")
	local float_width = 100
	local float_height = 30
	local row = math.floor((screen_height - float_height) / 2)
	local col = math.floor((screen_width - float_width) / 2)

	vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		width = float_width,
		height = float_height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	})

	vim.cmd("term " .. tui)
	vim.schedule(function()
		vim.cmd("startinsert")
	end)
end

local function float_prompt(callback)
	local buffer = vim.api.nvim_create_buf(false, true)
	vim.bo[buffer].buftype = "prompt"

	local screen_width = vim.api.nvim_get_option("columns")
	local screen_height = vim.api.nvim_get_option("lines")
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

vim.keymap.set("n", "<leader>ui", function()
	float_prompt(T)
end, {})
