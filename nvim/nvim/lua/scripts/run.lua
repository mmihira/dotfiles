local M = {}

tterm = require("toggleterm")

local exec_in_term = function(command)
	tterm.exec(command, 1, nil, nil, "float", "main_term", false, true)
end

local run_lua = function()
	vim.api.nvim_command(":luafile %")
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

		local out = scan.scan_dir(parent_path:absolute(), { hidden = true, depth = 1 })
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

	if not foundMake then
		local debug_path = parent_path:joinpath("out", "Debug")
		local out = scan.scan_dir(debug_path:absolute(), { hidden = true, depth = 1 })
		for _, item in ipairs(out) do
			if string.find(item, "build.ninja", 1, true) then
				foundMake = true
				parent_path = debug_path
				break
			end
		end
	end

	if foundMake then
		local _cmd = "(cd " .. parent_path:absolute() .. "; ninja run -j 8" .. ")"
		exec_in_term(_cmd)
	else
		print("Could not found makefile")
	end
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
end
M.run_file = run_file

return M
