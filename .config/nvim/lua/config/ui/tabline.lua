function _G.Tabline_Gettabs()
	local tabs = vim.tbl_filter(vim.api.nvim_tabpage_is_valid, vim.api.nvim_list_tabpages())
	local str = ""
	for i, tab in ipairs(tabs) do
		if tab == vim.api.nvim_get_current_tabpage() then
			str = str .. "%#TabLineSel# " .. tostring(i) .. " %#TabLine#"
		else
			str = str .. " " .. tostring(i) .. " "
		end
	end
	return str
end

function _G.Tabline_Getbuffers()
	local buffers = vim.iter(vim.api.nvim_list_bufs())
		:filter(function(buf)
			return vim.bo[buf].buflisted and vim.api.nvim_buf_is_valid(buf)
		end)
		:totable()
	local str = ""
	local buffer_line_length = 0
	local slices = { 0 }
	local current_slice = 1
	for _, buf in ipairs(buffers) do
		local buf_name = vim.api.nvim_buf_get_name(buf)
		if buf_name == "" then
			if vim.fn.win_gettype() ~= "" then
				break
			end
			buf_name = "[No Name]"
		else
			if buf_name ~= "health://" then
				buf_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
			end
		end
		buffer_line_length = buffer_line_length + #buf_name
		if buf == vim.api.nvim_get_current_buf() then
			current_slice = #slices
			str = str .. "%#TabLineSel# " .. buf_name .. " %#TabLine#"
		else
			str = str .. " " .. buf_name .. " "
		end
		if buffer_line_length > 100 then
			table.insert(slices, #str)
			buffer_line_length = 0
		end
	end
	table.insert(slices, #str)
	local buffer_line = string.sub(str, slices[current_slice] + 1, slices[current_slice + 1])
	if #slices == 2 then
		return str
	elseif current_slice == #slices - 1 then
		return "... " .. buffer_line
	elseif current_slice == 1 then
		return buffer_line .. " ..."
	else
		return "... " .. buffer_line .. " ..."
	end
	return
end

local tabline = ""

-- Left side
tabline = tabline .. "%{%v:lua.Tabline_Getbuffers()%}"

-- Align
tabline = tabline .. "%="

-- Right side
tabline = tabline .. "%{%v:lua.Tabline_Gettabs()%}"

return tabline
