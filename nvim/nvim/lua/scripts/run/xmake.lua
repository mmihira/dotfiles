local M = {}

function M.find_root(file_full_path)
	if file_full_path == nil or file_full_path == "" then
		return nil
	end

	local start = vim.fs.dirname(file_full_path)
	local found = vim.fs.find("xmake.lua", {
		upward = true,
		path = start,
		stop = vim.uv.os_homedir(),
	})

	if vim.tbl_isempty(found) then
		return nil
	end

	return vim.fs.dirname(found[1])
end

function M.resolve_build_target(file_full_path)
	local root = M.find_root(file_full_path)
	if not root then
		return nil, "No xmake.lua root found"
	end

	local rel = vim.fs.relpath(root, file_full_path)
	if not rel then
		return nil, string.format("Could not make '%s' relative to '%s'", file_full_path, root)
	end

	local script = string.format(
		[[
import("core.project.project")
for _, target in pairs(project.targets()) do
    for _, src in ipairs(target:sourcefiles()) do
        if src:find(%q, 1, true) then
            print(target:name())
            return
        end
    end
end
]],
		rel
	)

	local result = vim.system({ "xmake", "lua", "--stdin" }, {
		cwd = root,
		text = true,
		stdin = script,
	}):wait()

	if result.code ~= 0 then
		local stderr = vim.trim(result.stderr or "")
		if stderr == "" then
			stderr = "xmake lua --stdin failed"
		end
		return nil, stderr
	end

	local target = vim.trim(result.stdout or ""):match("([^\n]+)")
	return {
		root = root,
		rel = rel,
		target = target ~= "" and target or nil,
	}
end

function M.find_manifest_path(root)
	local manifests = vim.fn.globpath(root .. "/build", "**/dll_manifest.jsonl", false, true)
	table.sort(manifests)
	return manifests[1]
end

function M.find_dll_target(root, file_full_path)
	local manifest_path = M.find_manifest_path(root)
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
				if file_full_path == root .. "/" .. src then
					f:close()
					return target
				end
			end
		end
	end

	f:close()
	return nil
end

function M.resolve_hotreload_target(file_full_path)
	local root = M.find_root(file_full_path)
	if not root then
		return nil, "No xmake.lua root found"
	end

	local rel = vim.fs.relpath(root, file_full_path)
	if not rel then
		return nil, string.format("Could not make '%s' relative to '%s'", file_full_path, root)
	end

	local dll_target = M.find_dll_target(root, file_full_path)
	if not dll_target then
		return nil, "Could not find dll target for " .. rel
	end

	local manifest_path = M.find_manifest_path(root)
	if not manifest_path or manifest_path == "" then
		return nil, "Could not find dll_manifest.jsonl under " .. root .. "/build"
	end

	local touch_script = vim.fs.joinpath(root, "tools", "touch_hotreload.lua")
	if vim.fn.filereadable(touch_script) ~= 1 then
		return nil, "Could not find hotreload script at " .. touch_script
	end

	return {
		root = root,
		rel = rel,
		dll_target = dll_target,
		manifest_path = manifest_path,
		touch_script = touch_script,
	}
end

return M
