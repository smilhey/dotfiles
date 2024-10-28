local M = {}

local open_code = "\27[200~"
local close_code = "\27[201~"
local cr = "\r"

M.supported = { "ipython", "python", "luajit" }

M.commentstring = {
	luajit = "--",
	python = "#",
	ipython = "#",
}

function M.pad(selection, repl, buf, mark)
	local padded_selection = vim.tbl_map(function(str)
		return str .. (" "):rep(80 - #str) .. M.commentstring[repl] .. "[IN]"
	end, selection)
	table.insert(
		padded_selection,
		1,
		(" "):rep(80) .. M.commentstring[repl] .. "[MARK START] : " .. buf .. " - " .. mark
	)
	table.insert(padded_selection, (" "):rep(80) .. M.commentstring[repl] .. "[MARK END]")
	return padded_selection
end

M.input = {
	default = function(selection)
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		return open_code .. table.concat(lines, cr) .. close_code .. cr
	end,
	luajit = function(selection)
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		return table.concat(lines, "\n") .. "\r"
	end,
	python = function(selection)
		local input = ""
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		local previous_indentation = 0
		for i, line in ipairs(lines) do
			line = line .. "\n"
			local indentation = #line:match("^%s*")
			if previous_indentation > 0 and indentation == 0 then
				line = "\n" .. line
			end
			previous_indentation = indentation
			if i == #lines and indentation > 0 then
				line = line .. "\n"
			end
			input = input .. line
		end
		return input
	end,
	ipython = function(selection)
		local input = ""
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		for i, line in ipairs(lines) do
			line = line .. "\r"
			local indentation = #line:match("^%s*")
			if i == #lines and indentation > 0 then
				line = line .. "\r"
			end
			input = input .. line
		end
		return input
	end,
}

M.output = {
	luajit = function(data)
		local lines = {}
		for _, line in ipairs(data) do
			line = line:gsub("> ", "")
			line = line:gsub("[>\r]", "")
			local is_output = line:find("[IN]", -4, true) == nil and line:find("[MARK ", 1, true) == nil and line ~= ""
			lines[#lines + 1] = is_output and line or nil
		end
		return lines
	end,
	python = function(data)
		local lines = {}
		for _, line in ipairs(data) do
			line = line:gsub("[>\r]", "")
			local is_output = line:find("[IN]", -4, true) == nil
				and line:find("[MARK ", 1, true) == nil
				and line ~= ""
				and line:match("^%s*$") == nil
				and line:find("%.%.%.") ~= 1
			lines[#lines + 1] = is_output and line or nil
		end
		return lines
	end,
	ipython = function(data)
		local lines = {}
		for _, line in ipairs(data) do
			line = line:gsub("\27%[[0-9;?]*[a-zA-Z]", "")
			line = line:gsub("\r", "")
			local is_output = line:find("In %[") == nil
				and line:find("   ...:") == nil
				and line:find("[IN]", -4, true) == nil
				and line:find("[MARK ", 1, true) == nil
				and line ~= ""
			lines[#lines + 1] = is_output and line or nil
		end
		return lines
	end,
}

return M
