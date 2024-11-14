local M = {}

function M.handler(err, progress, ctx)
	if err then
		return
	end
	local value = progress.value
	local title = value.title and value.title or ""
	local percentage = value.percentage and value.percentage or 0
	local display = title == "Loading workspace" and percentage > 0
	vim.g.statusline_lsp_progress = display and title .. " : " .. tostring(percentage) .. "/100" or ""
	vim.cmd.redrawstatus()
end

function M.setup(config)
	local old_handler = vim.lsp.handlers["$/progress"]
	vim.lsp.handlers["$/progress"] = function(...)
		if old_handler then
			old_handler(...)
		end
		M.handler(...)
	end
end

return M
