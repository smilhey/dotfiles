--- Prints the inspected object
-- @param object: The object to inspect and print
function P(object)
	print(vim.inspect(object))
end

--- Returns a function that calls the provided function with the provided arguments
-- @param fn: The function to call
-- @param args: The arguments to pass to the function
function F(fn, fargs)
	return function()
		fn(fargs)
	end
end

--- Checks if the current buffer's directory is a git repository
-- @return boolean: true if the directory is a git repository, false otherwise
function Git()
	local cwd = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
	return not vim.tbl_isempty(vim.fs.find(".git", { path = cwd, upward = true, stop = vim.fn.expand("~") }))
end
