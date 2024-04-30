-- Global lua print function for lua objects
function P(object)
	print(vim.inspect(object))
end

function F(fn, args)
	return function()
		fn(args)
	end
end
