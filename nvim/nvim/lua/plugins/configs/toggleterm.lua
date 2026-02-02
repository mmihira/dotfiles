local present, tterm = pcall(require, "toggleterm")
if not present then
	return
end

function strsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

MAX_LOOKBACK = 100

function populate_qf_with_cpp_errors(bn)
	local qlistresults = {}
	local line_count = vim.api.nvim_buf_line_count(bn)

	-- Look through all lines in the buffer
	for i = 1, line_count do
		local line = vim.api.nvim_buf_get_lines(bn, i - 1, i, false)[1]

		-- Match C++ compiler error/warning pattern: /path/to/file.cpp:line:col: error/warning: message
		-- Pattern matches: filepath:line:column: type: message
		local filepath, line_num, col_num, err_type, message =
			string.match(line, "^([^:]+%.cpp):(%d+):(%d+):%s*([^:]+):%s*(.+)$")

		if filepath and line_num then
			local item = {
				filename = filepath,
				lnum = tonumber(line_num),
				col = tonumber(col_num) or 1,
				type = err_type:match("error") and "E" or "W",
				text = (err_type .. ": " .. message):gsub("%s+", " "),
			}

			if item.type == "E" then
				-- Prioritize errors by inserting them at the beginning
				table.insert(qlistresults, 1, item)
			else
				-- Warnings go to the end
				table.insert(qlistresults, item)
			end
		end
	end

	if #qlistresults > 0 then
		vim.fn.setqflist({}, " ", { title = "C++ Build Errors", id = "$", items = qlistresults })
	end
end

function process_cpp_build_line(line)
	-- Match C++ compiler error/warning pattern: /path/to/file.cpp:line:col: error/warning: message
	local filepath, line_num, col_num, err_type, message =
		string.match(line, "^([^:]+%.cpp):(%d+):(%d+):%s*([^:]+):%s*(.+)$")

	if filepath and line_num then
		local item = {
			filename = filepath,
			lnum = tonumber(line_num),
			col = tonumber(col_num) or 1,
			type = err_type:match("error") and "E" or "W",
			text = (err_type .. ": " .. message):gsub("%s+", " "),
		}
		-- Append to quickfix list (action 'a' means append)
		vim.fn.setqflist({}, "a", { title = "C++ Build Errors", items = { item } })
	end
end

function populate_qf_with_go_stack(bn)
	qlistresults = {}

	endinx = vim.api.nvim_buf_line_count(bn)
	inx = vim.api.nvim_buf_line_count(bn)

	while inx > 0 and (endinx - inx) < MAX_LOOKBACK do
		local bufrlines = vim.api.nvim_buf_get_lines(bn, inx - 1, inx, false)

		if string.match(bufrlines[1], ".+/.*.go:") then
			local strsplit0 = strsplit(bufrlines[1], ":")
			local lsplit = strsplit(strsplit0[2], " ")
			local txt = vim.api.nvim_buf_get_lines(bn, inx - 2, inx - 1, false)
			local item = {
				filename = string.gsub(strsplit0[1], "%s+", ""),
				lnum = tonumber(lsplit[1]),
				col = 1,
				pos = inx,
				text = string.gsub(txt[1], "%s+", ""),
			}
			vim.print(txt)
			table.insert(qlistresults, item)
		end

		if string.match(bufrlines[1], "goroutine.*[running]") then
			inx = -1
		end

		inx = inx - 1
	end

	qlistresultsordered = {}
	inx = #qlistresults
	while inx > 0 do
		table.insert(qlistresultsordered, qlistresults[inx])
		inx = inx - 1
	end

	vim.fn.setqflist({}, " ", { title = "StackTrace", id = "$", items = qlistresultsordered })
end

local function is_go_project()
	local cwd = vim.fn.getcwd()
	local has_go_mod = vim.fn.filereadable(cwd .. "/go.mod") == 1
	local has_go_files = vim.fn.glob(cwd .. "/**/*.go", false, true)[1] ~= nil
	return has_go_mod or has_go_files
end

local function is_cpp_project()
	local cwd = vim.fn.getcwd()
	local has_cmake = vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1
	local has_cpp_files = vim.fn.glob(cwd .. "/**/*.cpp", false, true)[1] ~= nil
	return has_cmake or has_cpp_files
end

tterm.setup({
	on_open = function(t)
		if t.display_name == "main_term" or t.display_name == "build_term" then
			vim.fn.setqflist({}, "r", { title = "C++ Build Errors" })
		end
	end,
	on_close = function(t)
		-- if t.display_name == "main_term" or t.display_name == "build_term" then
		-- 	-- Schedule processing in next event loop to avoid blocking stdout
		-- 	vim.schedule(function()
		-- 		if is_cpp_project() then
		-- 			populate_qf_with_cpp_errors(t.bufnr)
		-- 		end
		-- 	end)
		-- end
	end,
})
