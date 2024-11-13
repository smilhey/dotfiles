local M = {}

function M.create_item(str, hl_group)
	hl_group = hl_group and hl_group or "StatusLine"
	return "%#" .. hl_group .. "#" .. str .. "%#StatusLine# "
end

function M.get_mode()
	local mode_table = {
		n = { mode = " NORMAL ", hl = "Search" },
		v = { mode = " VISUAL ", hl = "Visual" },
		V = { mode = " VISUAL ", hl = "Visual" },
		["\22"] = { mode = " VISUAL ", hl = "Visual" },
		s = { mode = " SELECT ", hl = "hlSelect" },
		i = { mode = " INSERT ", hl = "Todo" },
		R = { mode = " REPLACE ", hl = "Keyword" },
		t = { mode = " TERMINAL ", hl = "Cursor" },
		c = { mode = " COMMAND ", hl = "ModeMsg" },
	}
	local mode = vim.api.nvim_get_mode().mode
	if vim.fn.win_gettype() == "command" then
		return M.create_item(" COMMAND ", "ModeMsg")
	end
	if mode_table[mode] == nil then
		return M.create_item(" NORMAL ", "Search")
	else
		return M.create_item(mode_table[mode].mode, mode_table[mode].hl)
	end
end

function M.get_diagnostics()
	local lsp_progress = vim.g.statusline_lsp_progress and vim.g.statusline_lsp_progress or ""
	local diagnostics = ""
	if not vim.diagnostic.is_enabled() then
		return diagnostics
	end
	for prefix, type in pairs({
		E = { vim.diagnostic.severity.ERROR, "DiagnosticError" },
		W = { vim.diagnostic.severity.WARN, "DiagnosticWarn" },
		I = { vim.diagnostic.severity.INFO, "DiagnosticInfo" },
		H = { vim.diagnostic.severity.HINT, "DiagnosticHint" },
	}) do
		local count = #vim.diagnostic.get(0, { severity = type[1] })
		if count > 0 then
			diagnostics = diagnostics .. M.create_item(prefix .. " : " .. tostring(count), type[2])
		end
	end
	return lsp_progress .. diagnostics
end

function M.get_cwd()
	local cwd = ""
	if vim.bo.buftype == "" then
		local path = vim.fn.fnamemodify(vim.fn.getcwd(0), ":~")
		cwd = vim.fn.pathshorten(path, math.floor(vim.fn.winwidth(0) * 0.25))
	end
	return M.create_item(cwd)
end

function M.get_branch()
	local branch = vim.g.branch and vim.g.branch or ""
	branch = branch ~= "" and " " .. branch or ""
	return M.create_item(branch)
end

function M.get_search()
	local search = ""
	local ok, searchcount = pcall(vim.fn.searchcount)

	if ok and not vim.tbl_isempty(searchcount) and searchcount["total"] > 0 then
		search = "  : " .. searchcount["current"] .. "∕" .. searchcount["total"]
	end
	return M.create_item(search)
end

function M.get_macro()
	local macro = ""
	local recording_register = vim.fn.reg_recording()
	if recording_register ~= "" then
		macro = "rec @" .. recording_register
	end
	return M.create_item(macro, "ModeMsg")
end

function M.get_time()
	local date = os.date("T - %H:%M")
	return M.create_item(date)
end

function M.get_venv()
	-- if vim.bo.filetype ~= "python" then
	-- 	return ""
	-- end
	local venv = ""
	local conda_env = os.getenv("CONDA_DEFAULT_ENV")
	local venv_path = os.getenv("VIRTUAL_ENV")
	if conda_env then
		venv = string.format("  %s (conda)", conda_env)
	elseif venv_path then
		venv = vim.fn.fnamemodify(venv_path, ":t")
		venv = string.format("  %s (venv)", venv)
	end
	return M.create_item(venv, "String")
end

function M.get()
	local width = math.ceil(vim.o.columns * 0.4)
	local truncator_position = "%<"
	local align_rhs = "%="
	local sep = " "
	local lhs = "%-"
		.. width
		.. "."
		.. width
		.. "("
		.. M.get_mode()
		.. sep
		.. truncator_position
		.. M.get_cwd()
		.. sep
		.. M.get_branch()
		.. "%)"
	local mid = M.get_diagnostics()
	local rhs = "%"
		.. width
		.. "."
		.. width
		.. "("
		.. M.get_macro()
		.. sep
		.. M.get_venv()
		.. sep
		.. "%l/%L,%c %m "
		.. sep
		.. M.get_time()
		.. "%)"
	return lhs .. align_rhs .. mid .. align_rhs .. rhs
end

return M
