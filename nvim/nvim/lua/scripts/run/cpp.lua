local scan = require("plenary.scandir")
local exec_in_term = require("scripts.run.term")
local project = require("scripts.run.project")

local find_manifest_path = function(project_root)
	local manifests = vim.fn.globpath(project_root .. "/build", "**/dll_manifest.jsonl", false, true)
	table.sort(manifests)
	return manifests[1]
end

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

return function(file_path)
	local xmake_root = project.find_project_root(file_path, { "xmake.lua" })

	if xmake_root then
		local root = xmake_root:absolute()
		local dll_target = find_dll_target(root, file_path:absolute())

		if dll_target then
			local manifest_path = find_manifest_path(root)
			exec_in_term(
				string.format(
					"(cd '%s' && luajit tools/touch_hotreload.lua %s %s && xmake build-capture %s)",
					root,
					manifest_path,
					dll_target,
					dll_target
				)
			)
		else
			exec_in_term(string.format("(cd '%s' && xmake run)", root))
		end

		return
	end

	local find_make_loop = true
	local found_make = false
	local parent_path = file_path

	while find_make_loop do
		parent_path = parent_path:parent()
		local out = scan.scan_dir(parent_path:absolute(), { hidden = true, depth = 1, add_dirs = true })

		for _, item in ipairs(out) do
			if string.find(item, ".git", 1, true) then
				find_make_loop = false
			end

			if string.find(item, "Makefile", 1, true) then
				find_make_loop = false
				found_make = true
			end
		end
	end

	local build_path = parent_path:joinpath("out", "Debug")
	if not found_make then
		local out = scan.scan_dir(build_path:absolute(), { hidden = true, depth = 1 })

		for _, item in ipairs(out) do
			if string.find(item, "build.ninja", 1, true) then
				found_make = true
				break
			end
		end
	end

	if found_make then
		local root = parent_path:absolute()
		local dll_target = find_dll_target(root, file_path:absolute())
		local run_cmd

		if dll_target then
			run_cmd = string.format("(cd '%s' && ninja -C out/Debug %s)", root, dll_target)
		else
			run_cmd = string.format(
				"(cd '%s' && "
					.. "(ninja -C out/Debug check_module_imports -j 8 || cmake -B out/Debug -G Ninja) && "
					.. "ninja -C out/Debug run -j 8)",
				root
			)
		end

		exec_in_term(run_cmd)
	else
		print("Could not found makefile")
	end
end
