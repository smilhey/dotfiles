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
	local buffers = vim.tbl_filter(function(buf)
		return vim.bo[buf].buflisted and vim.api.nvim_buf_is_valid(buf)
	end, vim.api.nvim_list_bufs())
	local str = ""
	for i, buf in ipairs(buffers) do
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
		if buf == vim.api.nvim_get_current_buf() then
			str = str .. "%#TabLineSel# " .. buf_name .. " %#TabLine#"
		else
			str = str .. " " .. buf_name .. " "
		end
	end
	return str
end

local tabline = ""

-- Left side
tabline = tabline .. "%{%v:lua.Tabline_Getbuffers()%}"

-- Align
tabline = tabline .. "%="

-- Right side
tabline = tabline .. "%{%v:lua.Tabline_Gettabs()%}"

return tabline
