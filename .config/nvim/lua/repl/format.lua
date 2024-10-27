local M = {}

M.supported = { "ipython", "python", "luajit" }

M.commentstring = {
	luajit = "--",
	python = "#",
	ipython = "#",
}

M.input = {
	default = function(selection)
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		return table.concat(lines, "\n") .. "\r"
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
			local is_output = line:find(M.commentstring.luajit .. "IN") == nil
				and line:find("[MARK ", 1, true) == nil
				and line ~= ""
			lines[#lines + 1] = is_output and line or nil
		end
		return lines
	end,
	python = function(data)
		local lines = {}
		for _, line in ipairs(data) do
			line = line:gsub("\r", "")
			local is_input = line:find(M.commentstring.python .. "IN") ~= nil or line:find("[MARK ", 1, true) ~= nil

			lines[#lines + 1] = not is_input and line or nil
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
				and line:find(M.commentstring.python .. "IN") == nil
				and line:find("[MARK ", 1, true) == nil
				and line ~= ""
			lines[#lines + 1] = is_output and line or nil
		end
		return lines
	end,
}

return M
