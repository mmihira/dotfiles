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

local run_lua = function(file_path)
	local file_full_path = file_path:absolute()
	local cmd = parse_run_block(file_full_path)
	if cmd then
		local parent_dir = vim.fn.fnamemodify(file_full_path, ":h")
		exec_in_term("(cd " .. parent_dir .. "; " .. cmd .. ")")
	else
		local parent_path = file_path:parent()
		local rel = file_path:make_relative(parent_path:absolute())
		local _cmd = "(cd " .. parent_path:absolute() .. "; " .. "luajit " .. rel .. ")"
		exec_in_term(_cmd)
	end
end

local run_bash = function(file_path)
	local parent_path = file_path:parent()
	local rel = file_path:make_relative(parent_path:absolute())
	local _cmd = "(cd " .. parent_path:absolute() .. "; " .. "./" .. rel .. ")"
	exec_in_term(_cmd)
end

local find_project_root = function(file_path, marker_names)
	local scan = require("plenary.scandir")
	local parent_path = file_path

	while true do
		local next_parent = parent_path:parent()
		if next_parent:absolute() == parent_path:absolute() then
			return nil
		end
		parent_path = next_parent
		local absolute = parent_path:absolute()
		local out = scan.scan_dir(absolute, { hidden = true, depth = 1, add_dirs = true })
		local found_git = false

		for _, item in ipairs(out) do
			if string.find(item, ".git", 1, true) then
				found_git = true
			end

			for _, marker in ipairs(marker_names) do
				if string.find(item, marker, 1, true) then
					return parent_path
				end
			end
		end

		if found_git then
			return nil
		end
	end
end

local run_go = function(file_path)
	local parent_path = find_project_root(file_path, { "Makefile" })

	if parent_path then
		local _cmd = "(cd " .. parent_path:absolute() .. "; make run" .. ")"
		exec_in_term(_cmd)
	else
		print("Could not found makefile")
	end
end

local find_manifest_path = function(project_root)
	local manifests = vim.fn.globpath(project_root .. "/build", "**/dll_manifest.jsonl", false, true)
	table.sort(manifests)
	return manifests[1]
end

local find_manifest_path = function(project_root)
	local manifests = vim.fn.globpath(project_root .. "/build", "**/dll_manifest.jsonl", false, true)
	table.sort(manifests)
	return manifests[1]
end

local touch_state_constructors = function(project_root, target)
	local touch_hotreload = dofile(project_root .. "/tools/touch_hotreload.lua")
	local manifest_path = find_manifest_path(project_root)
	touch_hotreload.touch(manifest_path, "gameeditor")
end

-- Returns xmake_target string if file_full_path belongs to a hot-reload DLL,
-- nil otherwise. Reads build/**/dll_manifest.jsonl from the project root.
local find_dll_target = function(project_root, file_full_path)
	local manifest_path = find_manifest_path(project_root)
	if not manifest_path or manifest_path == "" then
		return nil
	end

	local f = io.open(manifest_path, "r")
	if not f then
		return nil
	end

	for line in f:lines() do
		local target = line:match('"xmake_target"%s*:%s*"([^"]+)"')
		local sources_str = line:match('"sources"%s*:%s*%[([^%]]*)%]')
		if target and sources_str then
			for src in sources_str:gmatch('"([^"]+)"') do
				if file_full_path == project_root .. "/" .. src then
					f:close()
					return target
				end
			end
		end
	end
	f:close()
	return nil
end

local run_cpp = function(file_path)
	local scan = require("plenary.scandir")
	local xmake_root = find_project_root(file_path, { "xmake.lua" })

	if xmake_root then
		local dll_target = find_dll_target(xmake_root:absolute(), file_path:absolute())
		if dll_target then
			-- touch_state_constructors(xmake_root:absolute(), dll_target)
			local manifest_path = find_manifest_path(xmake_root:absolute())
			exec_in_term(
				string.format(
					"(cd '%s' && luajit tools/touch_hotreload.lua "
						.. manifest_path
            .. " "
						.. dll_target
						.. " && xmake build-capture %s)",
					xmake_root:absolute(),
					dll_target
				)
			)
		else
			exec_in_term(string.format("(cd '%s' && xmake run)", xmake_root:absolute()))
		end
		return
	end

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
		local dll_target = find_dll_target(parent_path:absolute(), file_path:absolute())
		local run_cmd
		if dll_target then
			run_cmd = string.format("(cd '%s' && ninja -C out/Debug %s)", parent_path:absolute(), dll_target)
		else
			run_cmd = string.format(
				"(cd '%s' && "
					.. "(ninja -C out/Debug check_module_imports -j 8 || cmake -B out/Debug -G Ninja) && "
					.. "ninja -C out/Debug run -j 8)",
				parent_path:absolute()
			)
		end
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
		run_lua(file_path)
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
