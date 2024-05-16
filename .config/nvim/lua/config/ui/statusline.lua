local WIN_WIDTH_FILENAME_FRACTION = 0.07
local WIN_WIDTH_DIR_FRACTION = 0.03
local MAX_SPELL_ERRORS = 20

local LEFT_BRACE = "‹"
local RIGHT_BRACE = "›"

function _G.Statusline_Getmode()
	local mode_table = {
		n = { mode = "NORMAL", highlight = "StatusLine" },
		v = { mode = "VISUAL", highlight = "Visual" },
		V = { mode = "VISUAL", highlight = "Visual" },
		["\22"] = { mode = "VISUAL", highlight = "Visual" },
		s = { mode = "SELECT", highlight = "HighlightSelect" },
		i = { mode = "INSERT", highlight = "Todo" },
		R = { mode = "REPLACE", highlight = "Search" },
		t = { mode = "TERMINAL", highlight = "Cursor" },
		c = { mode = "COMMAND", highlight = "FloatShadow" },
	}
	local mode_current = vim.fn.mode()
	if vim.fn.win_gettype() == "command" then
		return "%#FloatShadow# COMMAND %#StatusLine# "
	end
	if mode_table[mode_current] == nil then
		return "%#Statusline# NORMAL"
	else
		return "%#"
			.. mode_table[mode_current:sub(1, 1)].highlight
			.. "# "
			.. mode_table[mode_current:sub(1, 1)].mode
			.. " %#StatusLine# "
	end
end

function _G.Statusline_DiagnosticStatus()
	if not vim.diagnostic.is_disabled() then
		local diagnostics_counts = {}
		for prefix, severity in pairs({
			E = vim.diagnostic.severity.ERROR,
			W = vim.diagnostic.severity.WARN,
			I = vim.diagnostic.severity.INFO,
			H = vim.diagnostic.severity.HINT,
		}) do
			local count = #vim.diagnostic.get(0, { severity = severity })

			if count > 0 then
				table.insert(diagnostics_counts, prefix .. count)
			end
		end
		if #diagnostics_counts > 0 then
			return LEFT_BRACE .. "D : " .. table.concat(diagnostics_counts, ",") .. RIGHT_BRACE .. " "
		else
			return ""
		end
	end
	return ""
end

function _G.Statusline_Getcwd()
	if vim.bo.filetype ~= "help" and vim.bo.filetype ~= "man" and vim.bo.buftype ~= "terminal" then
		local path = vim.fn.fnamemodify(vim.fn.getcwd(0), ":~")
		return vim.fn.pathshorten(path, math.floor(vim.fn.winwidth(0) * WIN_WIDTH_DIR_FRACTION))
	else
		return ""
	end
end

vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
	callback = function()
		local branch = vim.system({ "git", "branch", "--show-current" }, { text = true }):wait().stdout
		vim.g.branch = string.sub(branch, 1, -2)
	end,
	desc = "Set cwd branch name",
})
function _G.StatusLine_Branch()
	return vim.g.branch
end

function _G.Statusline_Search()
	-- searchcount can fail e.g. if unbalanced braces in search pattern
	local ok, searchcount = pcall(vim.fn.searchcount)

	if ok and not vim.tbl_isempty(searchcount) and searchcount["total"] > 0 then
		return LEFT_BRACE .. "  : " .. searchcount["current"] .. "∕" .. searchcount["total"] .. RIGHT_BRACE
	end

	return ""
end

function _G.Statusline_MacroRecording()
	local recording_register = vim.fn.reg_recording()
	if recording_register == "" then
		return ""
	else
		return "%#WarningMsg#" .. LEFT_BRACE .. "rec @" .. recording_register .. RIGHT_BRACE .. "%#StatusLine# "
	end
end

vim.g.status_line_notify = {
	message = "",
	level = vim.log.levels.INFO,
}
function _G.StatusLine_notify()
	local hi = {
		["special"] = "DiagnosticOk",
		[vim.log.levels.DEBUG] = "Debug",
		[vim.log.levels.ERROR] = "ErrorMsg",
		[vim.log.levels.INFO] = "StatusLine",
		[vim.log.levels.TRACE] = "Normal",
		[vim.log.levels.WARN] = "WarningMsg",
		[vim.log.levels.OFF] = "Normal",
	}
	if vim.g.status_line_notify.level == nil then
		return ""
	end
	return "%#" .. hi[vim.g.status_line_notify.level] .. "#" .. vim.g.status_line_notify.message .. "%#StatusLine#"
end

local TRUNCATOR_POSITION = "%<"
local ALIGN_RHS = "%="
local SEPARATOR = " "

local statusline = ""

-- LHS - Mode
statusline = statusline .. "%{%v:lua.Statusline_Getmode()%}"

-- LHS - Cwd and git branch
statusline = statusline .. TRUNCATOR_POSITION
statusline = statusline .. "%{v:lua.Statusline_Getcwd()}"
statusline = statusline .. SEPARATOR
statusline = statusline .. " %{v:lua.StatusLine_Branch()}"
--
statusline = statusline .. ALIGN_RHS

-- Middle
statusline = statusline .. "%{%v:lua.StatusLine_notify()%}"

statusline = statusline .. ALIGN_RHS

-- RHS - Warnings
statusline = statusline .. "%{v:lua.Statusline_Search()}"
statusline = statusline .. SEPARATOR
statusline = statusline .. "%{%v:lua.Statusline_MacroRecording()%}"
statusline = statusline .. SEPARATOR
statusline = statusline .. "%{v:lua.Statusline_DiagnosticStatus()}"
statusline = statusline .. SEPARATOR

-- RHS - Location
statusline = statusline .. "%l/%L,%c "
statusline = statusline .. SEPARATOR

-- RHS - Filetype and edit status
statusline = statusline .. "%m %y"

return statusline
