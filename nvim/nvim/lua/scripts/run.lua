local M = {}

tterm = require("toggleterm")

local exec_in_term = function(command)
	tterm.exec(command, 1, nil, nil, "float", "main_term", false, true)
end

local parse_run_block = function(file_full_path)
	local lines = vim.fn.readfile(file_full_path)
	if #lines == 0 or not lines[1]:match("^%-%-%s*ASPERITE") then
		return nil
	end
	local capturing = false
	local cmd_parts = {}
	for _, line in ipairs(lines) do
		if line:match("^%-%-%s*RUN_START") then
			capturing = true
		elseif line:match("^%-%-%s*RUN_END") then
			break
		elseif capturing then
			local part = line:gsub("^%-%-", ""):gsub("^%s+", ""):gsub("\\%s*$", "")
			table.insert(cmd_parts, part)
		end
	end
	if #cmd_parts == 0 then
		return nil
	end
	return table.concat(cmd_parts, " ")
end

local run_lua = function()
	local file_full_path = vim.api.nvim_buf_get_name(0)
	local cmd = parse_run_block(file_full_path)
	if cmd then
		local parent_dir = vim.fn.fnamemodify(file_full_path, ":h")
		exec_in_term("(cd " .. parent_dir .. "; " .. cmd .. ")")
	else
		vim.api.nvim_command(":luafile %")
	end
end

local run_bash = function(file_path)
	local parent_path = file_path:parent()
	local rel = file_path:make_relative(parent_path:absolute())
	local _cmd = "(cd " .. parent_path:absolute() .. "; " .. "./" .. rel .. ")"
	exec_in_term(_cmd)
end

local run_go = function(file_path)
	local scan = require("plenary.scandir")

	local findMakeLoop = true
	local foundMake = false
	local parent_path = file_path:parent()

	while findMakeLoop do
		local out = scan.scan_dir(parent_path:absolute(), { hidden = true, depth = 1 })
		for _, item in ipairs(out) do
			if string.find(item, ".git", 1, true) then
				print("Found git without finding Makefile")
				findMakeLoop = false
			end

			if string.find(item, "Makefile", 1, true) then
				findMakeLoop = false
				foundMake = true
			end
		end

		if findMakeLoop then
			parent_path = parent_path:parent()
		end
	end

	if foundMake then
		local rel = file_path:make_relative(parent_path:absolute())
		local go_build_cmd = "go build -o go_app"
		local _cmd = "(cd " .. parent_path:absolute() .. "; make run" .. ")"
		exec_in_term(_cmd)
	else
		print("Could not found makefile")
	end
end

local run_cpp = function(file_path)
	local scan = require("plenary.scandir")

	local findMakeLoop = true
	local foundMake = false
	local foundGit = false
	local parent_path = file_path

	while findMakeLoop do
		parent_path = parent_path:parent()
		local out = scan.scan_dir(parent_path:absolute(), { hidden = true, depth = 1, add_dirs = true })
		for _, item in ipairs(out) do
			if string.find(item, ".git", 1, true) then
				findMakeLoop = false
				foundGit = true
			end

			if string.find(item, "Makefile", 1, true) then
				findMakeLoop = false
				foundMake = true
			end
		end
	end

	local build_path = parent_path:joinpath("out", "Debug")
	if not foundMake then
		local out = scan.scan_dir(build_path:absolute(), { hidden = true, depth = 1 })
		for _, item in ipairs(out) do
			if string.find(item, "build.ninja", 1, true) then
				foundMake = true
				break
			end
		end
	end

	if foundMake then
		local run_cmd = string.format(
			"(cd '%s' && "
				.. "(ninja -C out/Debug check_module_imports -j 8 || cmake -B out/Debug -G Ninja) && "
				.. "ninja -C out/Debug run -j 8)",
			parent_path:absolute()
		)
		exec_in_term(run_cmd)
	else
		print("Could not found makefile")
	end
end

local run_dot = function(file_path)
	local absolute_path = file_path:absolute()
	local filename = absolute_path:match("^.+/(.+)$")
	local output_name = filename:gsub("%.dot$", ".png")
	local output_path = "/tmp/" .. output_name

	local _cmd = "dot -Tpng " .. absolute_path .. " -o " .. output_path .. " && open -a 'Google Chrome' " .. output_path
	exec_in_term(_cmd)
end

local run_csv = function(file_path)
	local root_path = vim.fn.expand("~/c/ove/")
	local _cmd = "(cd " .. root_path .. "; ./out/Debug/ove --stats)"
	exec_in_term(_cmd)
end

local run_file = function()
	local plenary = require("plenary")
	local path = require("plenary.path")

	local file_full_path = vim.api.nvim_buf_get_name(0)
	local file_path = path.new(file_full_path)
	local filetype = plenary.filetype.detect_from_extension(file_full_path)

	if filetype == "lua" then
		run_lua()
	end
	if filetype == "sh" then
		run_bash(file_path)
	end
	if filetype == "go" then
		run_go(file_path)
	end
	if filetype == "cpp" then
		run_cpp(file_path)
	end
	if filetype == "c" then
		run_cpp(file_path)
	end
	if filetype == "dot" then
		run_dot(file_path)
	end
	if filetype == "csv" then
		run_csv(file_path)
	end
end
M.run_file = run_file

return M
