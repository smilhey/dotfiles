local M = {}

local open_code = "\27[200~"
local close_code = "\27[201~"
local cr = "\r"

M.supported = { "ipython", "python", "luajit", "ghci" }

M.commentstring = {
	luajit = "--",
	python = "#",
	ipython = "#",
	ghci = "--",
}

function M.is_end(str)
	return str:find("[MARK END]", 1, true) and true or false
end

function M.is_start(str)
	return str:find("[MARK START]", 1, true) and true or false
end

function M.pad(data, repl, buf, mark)
	local padded_selection = {}
	for line, newline in data:gmatch("([^\r\n]*)(\r?\n?)") do
		if line == "" and newline == "" then
			break
		elseif line == "" then
			table.insert(padded_selection, newline)
		else
			table.insert(padded_selection, line .. (" "):rep(120 - #line) .. M.commentstring[repl] .. "[IN]" .. newline)
		end
	end
	table.insert(
		padded_selection,
		1,
		(" "):rep(120) .. M.commentstring[repl] .. "[MARK START] : " .. buf .. " - " .. mark .. "\n"
	)
	table.insert(padded_selection, (" "):rep(120) .. M.commentstring[repl] .. "[MARK END]\n")
	return table.concat(padded_selection)
end

M.input = {
	default = function(selection)
		local lines = vim.tbl_filter(function(line)
			return line ~= ""
		end, selection)
		return open_code .. table.concat(lines, cr) .. close_code .. cr
	end,
	ghci = function(selection)
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
		local prev_indent = 0
		for i, line in ipairs(lines) do
			line = line .. "\r"
			local indent = #line:match("^%s*")
			if i == #lines and indent > 0 then
				line = line .. "\r"
			end
			if indent == 0 and prev_indent > 0 then
				line = "\r" .. line
			end
			prev_indent = indent
			input = input .. line
		end
		return input
	end,
}

M.output = {
	ghci = function(line)
		line = line:gsub("\27%[%??%d*[a-zA-Z]", "")
		line = line:gsub("ghci> ", "")
		line = line:gsub("\r", "")
		local is_output = line:find("[IN]", -4, true) == nil and line:find("[MARK ", 1, true) == nil and line ~= ""
		return is_output and line
	end,
	luajit = function(line)
		line = line:gsub("> ", "")
		line = line:gsub("[>\r]", "")
		local is_output = line:find("[IN]", -4, true) == nil and line:find("[MARK ", 1, true) == nil and line ~= ""
		return is_output and line
	end,
	python = function(line)
		line = line:gsub("[>\r]", "")
		local is_output = line:find("[IN]", -4, true) == nil
			and line:find("[MARK ", 1, true) == nil
			and line ~= ""
			and line:match("^%s*$") == nil
			and line:find("%.%.%.") ~= 1
		return is_output and line
	end,
	ipython = function(line)
		line = line:gsub("\27%[[0-9;?]*[a-zA-Z]", "")
		line = line:gsub("\r", "")
		local is_output = line:find("In %[") == nil
			and line:find("   ...:") == nil
			and line:find("#[IN]", 1, true) == nil
			and line:find("[MARK ", 1, true) == nil
			and line ~= ""
		return is_output and line
	end,
}

M.is_error = {
	ipython = function(line)
		local is_error = line:find("KeyboardInterrupt") or line:find("Traceback")
		return is_error and true or false
	end,
	python = function(line)
		local is_error = line:find("KeyboardInterrupt") or line:find("Traceback")
		return is_error and true or false
	end,
}

function M.parse(data, repl)
	local lines = {}
	local is_start, is_end, is_error = false, false, false
	for _, line in ipairs(data) do
		is_start = M.is_start(line) and true or is_start
		is_end = M.is_end(line) and true or is_end
		is_error = M.is_error[repl](line) and true or is_error
		if is_end then
			return lines, is_start, is_end, is_error
		end
		local output = M.output[repl](line)
		if output then
			lines[#lines + 1] = output
		end
	end
	return lines, is_start, is_end, is_error
end

return M
