local M = {}

tterm = require("toggleterm")

local exec_in_term = function(command)
	tterm.exec(command, 1, nil, nil, "float", "main_term", false, true)
end

local build_cpp = function(file_path)
	local scan = require("plenary.scandir")

	local findLoop = true
	local foundGit = false
	local parent_path = file_path

	while findLoop do
		parent_path = parent_path:parent()
		local out = scan.scan_dir(parent_path:absolute(), { hidden = true, depth = 1, add_dirs = true })
		for _, item in ipairs(out) do
			if string.find(item, ".git", 1, true) then
				findLoop = false
				foundGit = true
			end
		end
	end

	if foundGit then
		local rel = file_path:make_relative(parent_path:absolute())
		local target = "CMakeFiles/ove.dir/" .. rel .. ".o"
		local debug_path = parent_path:joinpath("out", "Debug")
		local _cmd = "(cd "
			.. debug_path:absolute()
			.. "; ninja -t clean "
			.. target
			.. " && ninja "
			.. target
			.. " -j 8)"
		exec_in_term(_cmd)
	else
		print("Could not find root directory")
	end
end

local build_file = function()
	local plenary = require("plenary")
	local path = require("plenary.path")

	local file_full_path = vim.api.nvim_buf_get_name(0)
	local file_path = path.new(file_full_path)
	local filetype = plenary.filetype.detect_from_extension(file_full_path)

	if filetype == "cpp" or filetype == "c" then
		build_cpp(file_path)
	end
end

M.build_file = build_file

return M
