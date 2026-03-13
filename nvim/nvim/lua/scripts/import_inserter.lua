local M = {}

local find_project_root = function()
	local scan = require("plenary.scandir")
	local path = require("plenary.path")

	local file_path = path.new(vim.api.nvim_buf_get_name(0))
	local parent_path = file_path

	while true do
		parent_path = parent_path:parent()
		local out = scan.scan_dir(parent_path:absolute(), { hidden = true, depth = 1, add_dirs = true })
		for _, item in ipairs(out) do
			if string.find(item, ".git", 1, true) then
				return parent_path:absolute()
			end
		end
	end
end

local file_hash = function(filepath)
	local handle = io.popen("md5 -q " .. vim.fn.shellescape(filepath) .. " 2>/dev/null")
	if not handle then
		return nil
	end
	local result = handle:read("*a"):gsub("%s+$", "")
	handle:close()
	if result == "" then
		return nil
	end
	return result
end

local ensure_compiled = function(root)
	local source = root .. "/tools/import_inserter.cpp"
	local binary = root .. "/out/Debug/import_inserter"
	local hash_file = root .. "/out/Debug/import_inserter_hash.txt"

	local current_hash = file_hash(source)
	if not current_hash then
		vim.notify("import_inserter: cannot hash source file", vim.log.levels.ERROR)
		return false
	end

	-- check stored hash
	local f = io.open(hash_file, "r")
	if f then
		local stored_hash = f:read("*a"):gsub("%s+$", "")
		f:close()
		if stored_hash == current_hash then
			return true
		end
	end

	-- compile
	vim.notify("import_inserter: compiling...", vim.log.levels.INFO)
	local compile_cmd = string.format(
		"clang++ -std=c++17 -O2 -o %s %s 2>&1",
		vim.fn.shellescape(binary),
		vim.fn.shellescape(source)
	)
	local output = vim.fn.system(compile_cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify("import_inserter: compile failed:\n" .. output, vim.log.levels.ERROR)
		return false
	end

	-- write hash
	f = io.open(hash_file, "w")
	if f then
		f:write(current_hash)
		f:close()
	end

	return true
end

M.run = function()
	local root = find_project_root()
	if not root then
		vim.notify("import_inserter: could not find project root", vim.log.levels.ERROR)
		return
	end

	if not ensure_compiled(root) then
		return
	end

	local binary = root .. "/out/Debug/import_inserter"
	local json_dir = root .. "/out/Debug/scanned_modules"
	local buf_path = vim.api.nvim_buf_get_name(0)

	-- gather all export jsons
	local jsons = vim.fn.glob(json_dir .. "/*_exports.json", false, true)
	if #jsons == 0 then
		vim.notify("import_inserter: no export JSONs found in " .. json_dir, vim.log.levels.ERROR)
		return
	end

	local cmd = vim.fn.shellescape(binary) .. " " .. vim.fn.shellescape(buf_path)
	for _, j in ipairs(jsons) do
		cmd = cmd .. " " .. vim.fn.shellescape(j)
	end

	local output = vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify("import_inserter: " .. output, vim.log.levels.ERROR)
		return
	end

	-- reload buffer to pick up changes
	vim.cmd("checktime")
	vim.notify("import_inserter: done", vim.log.levels.INFO)
end

return M
