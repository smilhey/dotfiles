--- Prints the inspected object
-- @param object: The object to inspect and print
function P(object)
	vim.schedule(function()
		vim.print(object)
	end)
end

--- Returns a function that calls the provided function with the provided arguments
-- @param fn: The function to call
-- @param args: The arguments to pass to the function
function F(fn, ...)
	local args = { ... }
	return function()
		fn(unpack(args))
	end
end
